class RssParserService
  def self.fetch_and_parse(url)
    feed = Feedjira.parse(HTTParty.get(url).body)
    {
      title: feed.title,
      description: feed.description,
      entries: feed.entries.map do |entry|
        {
          title: entry.title,
          content: entry.content || entry.summary,
          published_at: entry.published,
          link: entry.url
        }
      end
    }
  rescue => e
    Rails.logger.error("Error parsing RSS feed: #{e.message}")
    nil
  end
end
