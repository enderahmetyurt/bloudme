require "test_helper"
require "webmock/minitest"
require "minitest/mock"
require "ostruct"

class RssParserServiceTest < ActiveSupport::TestCase
  def setup
    @url = "https://example.com"
    @feed_url = "https://example.com/feed.xml"
    @favicon = "https://example.com/favicon.ico"
    @site_url = "https://example.com"

    @feed_entries = [
      OpenStruct.new(
        title: "Post 1",
        content: "Content 1",
        summary: nil,
        published: Time.parse("2023-01-01 12:00:00 UTC"),
        url: "https://example.com/post1"
      ),
      OpenStruct.new(
        title: "Post 2",
        content: nil,
        summary: "Summary 2",
        published: Time.parse("2023-01-01 12:00:00 UTC"),
        url: "https://example.com/post2"
      )
    ]

    @feed_object = OpenStruct.new(
      title: "Example Feed",
      description: "Example Description",
      entries: @feed_entries
    )

    @site_metadata = {
      feed_url: @feed_url,
      site_url: @site_url,
      favicon: @favicon
    }

    stub_feed_http
  end

  test "parses a standard RSS feed correctly" do
    mock_metadata_fetcher = Minitest::Mock.new
    mock_metadata_fetcher.expect :call, @site_metadata
    mock_http_response = Minitest::Mock.new
    mock_http_response.expect :body, "<rss></rss>"

    SiteMetadataFetcher.stub :new, ->(_url) { mock_metadata_fetcher } do
      HTTParty.stub :get, mock_http_response do
        Feedjira.stub :parse, @feed_object do
          result = RssParserService.fetch_and_parse(@url)

          assert_equal "Example Feed", result[:title]
          assert_equal @favicon, result[:favicon]
          assert_equal @feed_url, result[:feed_url]
          assert_equal @site_url, result[:site_url]
          assert_equal 2, result[:entries].size

          assert_equal "Post 1", result[:entries][0][:title]
          assert_equal "Content 1", result[:entries][0][:content]
          assert_equal "Post 2", result[:entries][1][:title]
          assert_equal "Summary 2", result[:entries][1][:content]
        end
      end
    end

    mock_metadata_fetcher.verify
    mock_http_response.verify
  end

  test "parses a YouTube feed with standard fields" do
    youtube_feed = OpenStruct.new(
      title: "YouTube Channel",
      entries: [
        OpenStruct.new(
          title: "Video 1",
          media_url: "https://media.example.com/video1.mp4",
          published: Time.parse("2023-01-01 12:00:00 UTC"),
          url: "https://youtube.com/watch?v=1",
          media_thumbnail_url: nil,
          youtube_channel_id: nil,
          youtube_video_id: nil
        )
      ]
    )

    youtube_metadata = {
      feed_url: "https://www.youtube.com/feeds/videos.xml?channel_id=test",
      site_url: "https://youtube.com",
      favicon: "https://youtube.com/favicon.ico"
    }

    metadata_fetcher = OpenStruct.new(call: youtube_metadata)
    http_response = OpenStruct.new(body: "<feed></feed>")

    SiteMetadataFetcher.stub :new, ->(_url) { metadata_fetcher } do
      HTTParty.stub :get, http_response do
        Feedjira.stub :parse, youtube_feed do
          result = RssParserService.fetch_and_parse("https://youtube.com")

          entry = result[:entries].first
          assert_equal "Video 1", entry[:title]
          assert_equal "https://media.example.com/video1.mp4", entry[:content]
        end
      end
    end
  end

  test "returns nil if feed download fails" do
    SiteMetadataFetcher.stub :new, ->(_url) { OpenStruct.new(call: nil) } do
      result = RssParserService.fetch_and_parse(@url)
      assert_nil result
    end
  end

  private

  def stub_feed_http
    stub_request(:get, @feed_url).to_return(body: "<rss></rss>", status: 200)
  end
end
