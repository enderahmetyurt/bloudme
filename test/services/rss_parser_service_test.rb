require "test_helper"
class RssParserServiceTest < ActiveSupport::TestCase
  test "fetches and parses an RSS feed" do
    VCR.use_cassette("feed") do
      response = RssParserService.fetch_and_parse("https://www.ruby-lang.org")

      assert_equal "Ruby RSS News", response[:title]
      assert_equal 10, response[:entries].size
      assert_equal "Ruby 3.4.2 veröffentlicht", response[:entries].first[:title]
      assert_equal "https://www.ruby-lang.org/de/news/2025/02/14/ruby-3-4-2-released/", response[:entries].first[:link]
    end
  end

  test "fetches and parses a YouTube channel" do
    VCR.use_cassette("youtube") do
      response = RssParserService.fetch_and_parse("https://www.youtube.com/@eayurt")

      assert_equal "Enderinko", response[:title]
      assert_equal 15, response[:entries].size
      assert_equal "Spor Günü Vlog", response[:entries].first[:title]
      assert_equal "https://www.youtube.com/watch?v=yXaebAWZwTI", response[:entries].first[:link]
    end
  end
end
