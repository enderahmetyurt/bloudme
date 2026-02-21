module Maintenance
  class DeduplicateFeedsTask < MaintenanceTasks::Task
    def collection
      Feed.select(:feed_url).group(:feed_url).having("COUNT(*) > 1").pluck(:feed_url)
    end

    def process(feed_url)
      feeds = Feed.where(feed_url: feed_url).order(:id)
      canonical = feeds.first
      duplicates = feeds.offset(1)

      duplicates.each do |duplicate|
        FeedSubscription.where(feed_id: duplicate.id).find_each do |sub|
          FeedSubscription.find_or_create_by!(user_id: sub.user_id, feed_id: canonical.id)
          sub.destroy
        rescue ActiveRecord::RecordNotUnique
          sub.destroy
        end

        canonical_links = canonical.articles.pluck(:link).to_set

        duplicate.articles.find_each do |dup_article|
          if canonical_links.include?(dup_article.link)
            canonical_article = canonical.articles.find_by(link: dup_article.link)

            UserArticle.where(article_id: dup_article.id).find_each do |ua|
              UserArticle.find_or_create_by!(user_id: ua.user_id, article_id: canonical_article.id) do |new_ua|
                new_ua.is_read = ua.is_read
              end
              ua.destroy
            rescue ActiveRecord::RecordNotUnique
              ua.destroy
            end

            Bookmark.where(article_id: dup_article.id).find_each do |bm|
              Bookmark.find_or_create_by!(user_id: bm.user_id, article_id: canonical_article.id)
              bm.destroy
            rescue ActiveRecord::RecordNotUnique
              bm.destroy
            end

            dup_article.destroy
          else
            dup_article.update!(feed_id: canonical.id)
          end
        end

        duplicate.destroy
      end
    end

    def count
      Feed.select(:feed_url).group(:feed_url).having("COUNT(*) > 1").count.size
    end
  end
end
