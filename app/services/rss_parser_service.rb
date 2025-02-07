class RssParserService
  def self.fetch_and_parse(url)
    feed = Feedjira.parse(HTTParty.get(url).body)
    if youtube_url?(url)
      {
        title: feed.title,
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
end
