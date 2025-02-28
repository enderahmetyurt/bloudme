class RssParserService
  YOUTUBE_RSS_URL = "https://www.youtube.com/feeds/videos.xml?channel_id".freeze
  FEED_SEARCH_ENDPOINT = "https://feedsearch.dev/api/v1/search".freeze

  def self.fetch_and_parse(feed_url)
    result = find_feed_url_favicon(feed_url)
    url = result[:feed_url]

    if youtube_url?(url)
      feed = Feedjira.parse(HTTParty.get(url).body)
      {
        title: feed.title,
        favicon: result[:favicon],
        is_podcast: result[:is_podcast],
        url: url,
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
    else
      feed = Feedjira.parse(HTTParty.get(url).body)
      {
        title: feed.title,
        description: feed.description,
        favicon: result[:favicon],
        is_podcast: result[:is_podcast],
        url: url,
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

  def self.find_feed_url_favicon(url)
    response = HTTParty.get(FEED_SEARCH_ENDPOINT, query: { url: url })
    result = JSON.parse(response.body)

    if result.is_a?(Hash) && result["error"]
      return nil
    end

    {
      feed_url: result.first["url"],
      site_url: result.first["site_url"],
      favicon: result.first["favicon"],
      is_podcast: result.first["is_podcast"]
    }
  end
end
