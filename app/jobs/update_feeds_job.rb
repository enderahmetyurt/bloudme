class UpdateFeedsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    fetch_feeds

    JobRun.create(
      job_class: self.class.name,
      user: User.find_by(is_admin: true),
      ran_at: Time.current,
      next_run_at: Time.current + 3.hours
    )
  rescue => e
    Rails.logger.error("MyJob failed for user #{user_id}: #{e.message}")
    raise e
  end

  private

  def fetch_feeds
    Feed.find_each do |feed|
      parsed_feed = RssParserService.fetch_and_parse(feed.feed_url)
      next unless parsed_feed

      # Batch load existing article links for this feed to avoid N+1 queries
      entry_links = parsed_feed[:entries].map { |entry| entry[:link] }
      existing_links = feed.articles.where(link: entry_links).pluck(:link).to_set

      new_articles = parsed_feed[:entries].filter_map do |entry|
        entry unless existing_links.include?(entry[:link])
      end

      # Bulk insert new articles
      if new_articles.any?
        feed.articles.insert_all(new_articles)

        subscriber_ids = feed.feed_subscriptions.pluck(:user_id)
        if subscriber_ids.any?
          new_article_ids = feed.articles.where(link: new_articles.map { |a| a[:link] }).pluck(:id)
          user_article_records = subscriber_ids.flat_map do |user_id|
            new_article_ids.map do |article_id|
              { user_id: user_id, article_id: article_id, is_read: false, created_at: Time.current, updated_at: Time.current }
            end
          end
          UserArticle.insert_all(user_article_records) if user_article_records.any?
        end
      end
    end
  end
end
