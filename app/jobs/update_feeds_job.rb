class UpdateFeedsJob < ApplicationJob
  queue_as :default

  def perform
    Feed.find_each do |feed|
      parsed_feed = RssParserService.fetch_and_parse(feed.url)
      next unless parsed_feed

      parsed_feed[:entries].each do |entry|
        unless feed.articles.exists?(link: entry[:link])
          feed.articles.create(entry)
        end
      end
    end
  end
end
