require "test_helper"
require "webmock/minitest"
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
        published: Time.now,
        url: "https://example.com/post1"
      ),
      OpenStruct.new(
        title: "Post 2",
        content: nil,
        summary: "Summary 2",
        published: Time.now,
        url: "https://example.com/post2"
      )
    ]

    @feed_object = OpenStruct.new(
      title: "Example Feed",
      description: "Example Description",
      entries: @feed_entries
    )

    override_site_metadata
    override_feedjira_parse
    stub_feed_http
  end

  test "parses a standard RSS feed correctly" do
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

  test "parses a YouTube feed with standard fields" do
    override_feedjira_parse(OpenStruct.new(
      title: "YouTube Channel",
      entries: [
        OpenStruct.new(
          title: "Video 1",
          content: "https://media.example.com/video1.mp4",
          published: Time.now,
          url: "https://youtube.com/watch?v=1"
        )
      ]
    ))

    result = RssParserService.fetch_and_parse("https://youtube.com")

    entry = result[:entries].first
    assert_equal "Video 1", entry[:title]
    assert_equal "https://media.example.com/video1.mp4", entry[:content]
  end

  test "returns nil if feed download fails" do
    override_httparty_with_error
    result = RssParserService.fetch_and_parse(@url)
    assert_nil result
  end

  private

  def override_site_metadata
    fake_metadata = OpenStruct.new(
      call: {
        feed_url: @feed_url,
        site_url: @site_url,
        favicon: @favicon
      }
    )

    SiteMetadataFetcher.singleton_class.class_eval do
      alias_method :original_new, :new unless method_defined?(:original_new)
      define_method(:new) { |_url| fake_metadata }
    end
  end

  def override_feedjira_parse(fake_result = @feed_object)
    Feedjira.singleton_class.class_eval do
      alias_method :original_parse, :parse unless method_defined?(:original_parse)
      define_method(:parse) { |_body| fake_result }
    end
  end

  def override_httparty_with_error
    HTTParty.singleton_class.class_eval do
      alias_method :original_get, :get unless method_defined?(:original_get)
      define_method(:get) { |_url| raise StandardError, "boom" }
    end
  end

  def stub_feed_http
    stub_request(:get, @feed_url).to_return(body: "<rss></rss>", status: 200)
  end

  def teardown
    # Restore SiteMetadataFetcher
    SiteMetadataFetcher.singleton_class.class_eval do
      if method_defined?(:original_new)
        remove_method :new
        alias_method :new, :original_new
        remove_method :original_new
      end
    end

    # Restore Feedjira
    Feedjira.singleton_class.class_eval do
      if method_defined?(:original_parse)
        remove_method :parse
        alias_method :parse, :original_parse
        remove_method :original_parse
      end
    end

    # Restore HTTParty
    HTTParty.singleton_class.class_eval do
      if method_defined?(:original_get)
        remove_method :get
        alias_method :get, :original_get
        remove_method :original_get
      end
    end
  end
end
