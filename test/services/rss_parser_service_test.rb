require "test_helper"
require "minitest/mock"
require "mocha/minitest"
require "ostruct"

class RssParserServiceTest < ActiveSupport::TestCase
  test "fetch_and_parse returns nil when SiteMetadataFetcher returns nil" do
    SiteMetadataFetcher.any_instance.stubs(:call).returns(nil)

    result = RssParserService.fetch_and_parse("https://example.com")

    assert_nil result
  end

  test "fetch_and_parse parses standard RSS feed successfully" do
    metadata_result = {
      feed_url: "https://example.com/feed.xml",
      favicon: "https://example.com/favicon.ico",
      site_url: "https://example.com"
    }

    SiteMetadataFetcher.any_instance.stubs(:call).returns(metadata_result)

    feed_body = '<?xml version="1.0"?><rss><channel><title>Test Feed</title><description>Test Description</description></channel></rss>'
    HTTParty.stubs(:get).returns(OpenStruct.new(body: feed_body))

    mock_feed = OpenStruct.new(
      title: "Test Feed",
      description: "Test Description",
      entries: [
        OpenStruct.new(
          title: "Test Entry",
          content: "Test content",
          summary: "Test summary",
          published: Time.now,
          url: "https://example.com/post1"
        )
      ]
    )

    Feedjira.stubs(:parse).returns(mock_feed)

    result = RssParserService.fetch_and_parse("https://example.com")

    assert_not_nil result
    assert_equal "Test Feed", result[:title]
    assert_equal "Test Description", result[:description]
    assert_equal "https://example.com/favicon.ico", result[:favicon]
    assert_equal 1, result[:entries].count
    assert_equal "Test Entry", result[:entries].first[:title]
    assert_equal "Test content", result[:entries].first[:content]
  end

  test "fetch_and_parse parses YouTube RSS feed successfully" do
    metadata_result = {
      feed_url: "https://www.youtube.com/feeds/videos.xml?channel_id=UC123",
      favicon: "https://youtube.com/favicon.ico",
      site_url: "https://youtube.com/channel/UC123"
    }

    SiteMetadataFetcher.any_instance.stubs(:call).returns(metadata_result)

    feed_body = '<?xml version="1.0"?><feed xmlns:yt="http://www.youtube.com/xml/schemas/2015"><title>YouTube Channel</title></feed>'
    HTTParty.stubs(:get).returns(OpenStruct.new(body: feed_body))

    mock_feed = OpenStruct.new(
      title: "YouTube Channel",
      entries: [
        OpenStruct.new(
          title: "Video Title",
          media_url: "https://youtube.com/watch?v=abc123",
          published: Time.now,
          url: "https://youtube.com/watch?v=abc123",
          media_thumbnail_url: "https://i.ytimg.com/vi/abc123/default.jpg",
          youtube_channel_id: "UC123",
          youtube_video_id: "abc123"
        )
      ]
    )

    Feedjira.stubs(:parse).returns(mock_feed)

    result = RssParserService.fetch_and_parse("https://youtube.com/channel/UC123")

    assert_not_nil result
    assert_equal "YouTube Channel", result[:title]
    assert_equal "https://youtube.com/favicon.ico", result[:favicon]
    assert_equal 1, result[:entries].count

    entry = result[:entries].first
    assert_equal "Video Title", entry[:title]
    assert_equal "https://youtube.com/watch?v=abc123", entry[:content]
    assert_equal "https://i.ytimg.com/vi/abc123/default.jpg", entry[:thumbnail]
    assert_equal "UC123", entry[:youtube_channel_id]
    assert_equal "abc123", entry[:youtube_video_id]
  end

  test "fetch_and_parse returns nil when parsing fails" do
    metadata_result = {
      feed_url: "https://example.com/feed.xml",
      favicon: "https://example.com/favicon.ico",
      site_url: "https://example.com"
    }

    SiteMetadataFetcher.any_instance.stubs(:call).returns(metadata_result)
    HTTParty.stubs(:get).raises(StandardError.new("Network error"))

    Rails.logger.expects(:error).with(regexp_matches(/Error parsing RSS feed/))

    result = RssParserService.fetch_and_parse("https://example.com")

    assert_nil result
  end

  test "youtube_url? returns true for YouTube URLs" do
    assert RssParserService.send(:youtube_url?, "https://youtube.com/feeds/videos.xml?channel_id=UC123")
    assert RssParserService.send(:youtube_url?, "https://www.youtube.com/feeds/videos.xml?channel_id=UC123")
    assert RssParserService.send(:youtube_url?, "https://youtu.be/abc123")
    assert RssParserService.send(:youtube_url?, "http://youtube.com/channel/UC123")
  end

  test "youtube_url? returns false for non-YouTube URLs" do
    refute RssParserService.send(:youtube_url?, "https://example.com/feed.xml")
    refute RssParserService.send(:youtube_url?, "https://vimeo.com/123456")
    refute RssParserService.send(:youtube_url?, "invalid-url")
  end

  test "youtube_url? handles invalid URIs gracefully" do
    refute RssParserService.send(:youtube_url?, "not a url at all")
    refute RssParserService.send(:youtube_url?, "")
    refute RssParserService.send(:youtube_url?, nil)
  end

  test "parse_standard_feed uses summary when content is nil" do
    metadata_result = {
      feed_url: "https://example.com/feed.xml",
      favicon: "https://example.com/favicon.ico",
      site_url: "https://example.com"
    }

    SiteMetadataFetcher.any_instance.stubs(:call).returns(metadata_result)

    feed_body = '<?xml version="1.0"?><rss><channel><title>Test Feed</title></channel></rss>'
    HTTParty.stubs(:get).returns(OpenStruct.new(body: feed_body))

    mock_feed = OpenStruct.new(
      title: "Test Feed",
      description: "Test Description",
      entries: [
        OpenStruct.new(
          title: "Test Entry",
          content: nil,
          summary: "Test summary",
          published: Time.now,
          url: "https://example.com/post1"
        )
      ]
    )

    Feedjira.stubs(:parse).returns(mock_feed)

    result = RssParserService.fetch_and_parse("https://example.com")

    assert_equal "Test summary", result[:entries].first[:content]
  end
end
