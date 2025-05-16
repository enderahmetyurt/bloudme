require "test_helper"
require "webmock/minitest"

class SiteMetadataFetcherTest < ActiveSupport::TestCase
  def setup
    @site_url = "https://example.com"
    @feed_url = "https://example.com/feed.xml"
    @favicon_url = "https://example.com/favicon.ico"
    @html = <<-HTML
      <html>
        <head>
          <link rel="shortcut icon" href="/favicon.ico" />
        </head>
      </html>
    HTML
  end

  test "returns feed_url, site_url and favicon successfully" do
    stub_feedbag_find([ @feed_url ])
    stub_request(:get, @site_url).to_return(body: @html)

    result = SiteMetadataFetcher.new(@site_url).call

    assert_equal @feed_url, result[:feed_url]
    assert_equal @site_url, result[:site_url]
    assert_equal @favicon_url, result[:favicon]
  end

  test "returns nil if Feedbag returns empty result" do
    stub_feedbag_find([])

    result = SiteMetadataFetcher.new(@site_url).call
    assert_nil result
  end

  test "returns nil if Feedbag raises an error (e.g. timeout)" do
    override_feedbag_find_with_error

    result = SiteMetadataFetcher.new(@site_url).call
    assert_nil result
  end

  test "still returns feed and site_url even if favicon cannot be fetched" do
    stub_feedbag_find([ @feed_url ])
    stub_request(:get, @site_url).to_raise(SocketError.new("network unreachable"))

    result = SiteMetadataFetcher.new(@site_url).call

    assert_equal @feed_url, result[:feed_url]
    assert_equal @site_url, result[:site_url]
    assert_nil result[:favicon]
  end

  test "handles invalid feed_url gracefully for site_url and favicon" do
    broken_feed_url = "https://example .com/%%invalid"
    stub_feedbag_find([ broken_feed_url ])

    result = SiteMetadataFetcher.new(@site_url).call

    assert_equal broken_feed_url, result[:feed_url]
    assert_nil result[:site_url]
    assert_nil result[:favicon]
  end

  private

  def stub_feedbag_find(return_value)
    Feedbag.singleton_class.class_eval do
      alias_method :original_find, :find
      define_method(:find) { |_url| return_value }
    end
  end

  def override_feedbag_find_with_error
    Feedbag.singleton_class.class_eval do
      alias_method :original_find, :find
      define_method(:find) { |_url| raise StandardError, "Feedbag error" }
    end
  end

  def teardown
    Feedbag.singleton_class.class_eval do
      if method_defined?(:original_find)
        remove_method :find
        alias_method :find, :original_find
        remove_method :original_find
      end
    end
  end
end
