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
      feed.articles.insert_all(new_articles) if new_articles.any?
    end
  end
end
