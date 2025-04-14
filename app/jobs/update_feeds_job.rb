class UpdateFeedsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    fetch_feeds

    JobRun.create(
      job_class: self.class.name,
      user: User.find_by(email_address: "enderyurt@gmail.com"),
      ran_at: Time.current,
      next_run_at: Time.current + 3.hours
    )
  rescue => e
    Rails.logger.error("MyJob failed for user #{user_id}: #{e.message}")
    raise e # job patlamalı mı? istemiyorsan burayı kaldır
  end

  private

  def fetch_feeds
    Feed.find_each do |feed|
      parsed_feed = RssParserService.fetch_and_parse(feed.feed_url)
      next unless parsed_feed

      parsed_feed[:entries].each do |entry|
        unless feed.articles.exists?(link: entry[:link])
          feed.articles.create(entry)
        end
      end
    end
  end
end
