class AddUniqueIndexToFeedsFeedUrl < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def up
    deduplicate_feeds
    remove_index :feeds, :feed_url, if_exists: true
    add_index :feeds, :feed_url, unique: true, algorithm: :concurrently
  end

  def down
    remove_index :feeds, :feed_url
  end

  private

  def deduplicate_feeds
    duplicate_urls = execute("SELECT feed_url FROM feeds GROUP BY feed_url HAVING COUNT(*) > 1").map { |r| r["feed_url"] }

    duplicate_urls.each do |feed_url|
      feed_ids = execute("SELECT id FROM feeds WHERE feed_url = #{connection.quote(feed_url)} ORDER BY id").map { |r| r["id"] }
      canonical_id = feed_ids.first
      duplicate_ids = feed_ids[1..]

      duplicate_ids.each do |dup_id|
        execute("UPDATE feed_subscriptions SET feed_id = #{canonical_id} WHERE feed_id = #{dup_id} AND user_id NOT IN (SELECT user_id FROM feed_subscriptions WHERE feed_id = #{canonical_id})")
        execute("DELETE FROM feed_subscriptions WHERE feed_id = #{dup_id}")

        execute(<<~SQL)
          UPDATE user_articles SET article_id = canonical_articles.id
          FROM articles AS dup_articles
          JOIN articles AS canonical_articles ON canonical_articles.feed_id = #{canonical_id} AND canonical_articles.link = dup_articles.link
          WHERE user_articles.article_id = dup_articles.id
          AND dup_articles.feed_id = #{dup_id}
          AND user_articles.user_id NOT IN (
            SELECT ua2.user_id FROM user_articles ua2 WHERE ua2.article_id = canonical_articles.id
          )
        SQL
        execute(<<~SQL)
          DELETE FROM user_articles WHERE article_id IN (
            SELECT id FROM articles WHERE feed_id = #{dup_id}
          )
        SQL

        execute(<<~SQL)
          UPDATE bookmarks SET article_id = canonical_articles.id
          FROM articles AS dup_articles
          JOIN articles AS canonical_articles ON canonical_articles.feed_id = #{canonical_id} AND canonical_articles.link = dup_articles.link
          WHERE bookmarks.article_id = dup_articles.id
          AND dup_articles.feed_id = #{dup_id}
          AND bookmarks.user_id NOT IN (
            SELECT b2.user_id FROM bookmarks b2 WHERE b2.article_id = canonical_articles.id
          )
        SQL
        execute(<<~SQL)
          DELETE FROM bookmarks WHERE article_id IN (
            SELECT id FROM articles WHERE feed_id = #{dup_id}
          )
        SQL

        execute("UPDATE articles SET feed_id = #{canonical_id} WHERE feed_id = #{dup_id} AND link NOT IN (SELECT link FROM articles WHERE feed_id = #{canonical_id})")
        execute("DELETE FROM articles WHERE feed_id = #{dup_id}")
        execute("DELETE FROM feeds WHERE id = #{dup_id}")
      end
    end
  end
end
