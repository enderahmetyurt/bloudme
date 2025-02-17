class RssParserService
  YOUTUBE_API_URL = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=channel".freeze
  YOUTUBE_RSS_URL = "https://www.youtube.com/feeds/videos.xml?channel_id".freeze
  YOUTUBE_API_KEY = Rails.application.credentials.dig(:youtube, :api_key)

  def self.fetch_and_parse(url)
    if youtube_url?(url)
      channel_id = find_channel_id(url)
      youtube_url = "#{YOUTUBE_RSS_URL}=#{channel_id}"
      feed = Feedjira.parse(HTTParty.get(youtube_url).body)
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

  def self.find_channel_id(url)
    channel_name = url.split("@").last
    channel_url = URI("#{YOUTUBE_API_URL}&q=#{URI.encode_www_form_component(channel_name)}&key=#{YOUTUBE_API_KEY}")
    response = Net::HTTP.get(channel_url)
    data = JSON.parse(response)

    if data["items"] && !data["items"].empty?
      data["items"][0]["id"]["channelId"]
    else
      nil
    end
  end
end
