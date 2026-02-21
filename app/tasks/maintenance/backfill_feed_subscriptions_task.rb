module Maintenance
  class BackfillFeedSubscriptionsTask < MaintenanceTasks::Task
    def collection
      Feed.all
    end

    def process(feed)
      FeedSubscription.find_or_create_by!(user_id: feed.user_id, feed_id: feed.id)
    rescue ActiveRecord::RecordNotUnique
      # race condition safe
    end

    def count
      Feed.count
    end
  end
end
