class RssParserService
  YOUTUBE_RSS_URL = "https://www.youtube.com/feeds/videos.xml?channel_id".freeze

  def self.fetch_and_parse(given_url)
    result = SiteMetadataFetcher.new(given_url).call
    return nil unless result

    feed_url = result[:feed_url]
    feed     = Feedjira.parse(HTTParty.get(feed_url).body)

    if youtube_url?(feed_url)
      parse_youtube_feed(feed, result)
    else
      parse_standard_feed(feed, result)
    end
  rescue => e
    Rails.logger.error("Error parsing RSS feed: #{e.message}")
    nil
  end

  private

  def self.youtube_url?(url)
    uri = URI.parse(url)
    return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    host = uri.host&.downcase&.sub(/^www\./, "")
    %w[youtube.com youtu.be].include?(host)
  rescue URI::InvalidURIError
    false
  end

  def self.parse_youtube_feed(feed, result)
    {
      title: feed.title,
      favicon: result[:favicon],
      feed_url: result[:feed_url],
      site_url: result[:site_url],
      entries: feed.entries.map do |entry|
        {
          title: entry.title,
          content: entry.media_url,
          published_at: entry.published,
          link: entry.url,
          thumbnail: entry.media_thumbnail_url,
          youtube_channel_id: entry.youtube_channel_id,
          youtube_video_id: entry.youtube_video_id
        }
      end
    }
  end

  def self.parse_standard_feed(feed, result)
    {
      title: feed.title,
      description: feed.description,
      favicon: result[:favicon],
      feed_url: result[:feed_url],
      site_url: result[:site_url],
      entries: feed.entries.map do |entry|
        {
          title: entry.title,
          content: entry.content || entry.summary,
          published_at: entry.published,
          link: entry.url
        }
      end
    }
  end
end
