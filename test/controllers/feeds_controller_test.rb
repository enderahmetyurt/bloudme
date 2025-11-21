require "test_helper"
require "webmock/minitest"
require "ostruct"

class FeedsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @user_with_no_feeds = users(:two)
    @feed = feeds(:one)
    @article = articles(:one)

    # Mock RssParserService for testing
    @mock_feed_data = {
      feed_url: "https://example.com/feed.xml",
      site_url: "https://example.com",
      favicon: "https://example.com/favicon.ico",
      is_podcast: false,
      title: "Test Feed",
      description: "Test Description",
      entries: [
        {
          title: "Test Article",
          content: "Test content",
          published_at: Time.current,
          link: "https://example.com/article1"
        }
      ]
    }
  end

  def sign_in_user
    sign_in_as(@user)
  end

  def sign_in_user_with_no_feeds
    sign_in_as(@user_with_no_feeds)
  end

  def stub_successful_rss_parsing
    RssParserService.class_eval do
      alias_method :original_fetch_and_parse, :fetch_and_parse if method_defined?(:fetch_and_parse)
    end

    mock_data = @mock_feed_data
    RssParserService.define_singleton_method(:fetch_and_parse) { |_url| mock_data }
    yield
  ensure
    restore_rss_parser_service
  end

  def stub_failed_rss_parsing
    RssParserService.class_eval do
      alias_method :original_fetch_and_parse, :fetch_and_parse if method_defined?(:fetch_and_parse)
    end

    RssParserService.define_singleton_method(:fetch_and_parse) { |_url| nil }
    yield
  ensure
    restore_rss_parser_service
  end

  def restore_rss_parser_service
    if RssParserService.respond_to?(:original_fetch_and_parse)
      RssParserService.define_singleton_method(:fetch_and_parse, RssParserService.method(:original_fetch_and_parse))
      RssParserService.class_eval { remove_method :original_fetch_and_parse if method_defined?(:original_fetch_and_parse) }
    end
  end

  # INDEX action tests
  test "should redirect unauthenticated user from index" do
    get feeds_url

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should redirect to new feed path when user has no feeds" do
    sign_in_user_with_no_feeds
    @user_with_no_feeds.feeds.destroy_all

    get feeds_url

    assert_response :redirect
    assert_redirected_to new_feed_path
  end

  test "should show feeds index when user has feeds" do
    sign_in_user

    get feeds_url

    assert_response :success
    assert assigns(:feeds)
    assert_equal @user.feeds, assigns(:feeds)
  end

  # NEW action tests
  test "should redirect unauthenticated user from new" do
    get new_feed_url

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should show new feed form for authenticated user" do
    sign_in_user

    get new_feed_url

    assert_response :success
    assert assigns(:feed)
    assert_instance_of Feed, assigns(:feed)
    assert assigns(:feed).new_record?
  end

  # CREATE action tests
  test "should redirect unauthenticated user from create" do
    post feeds_url, params: { feed: { feed_url: "https://example.com/feed.xml" } }

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should create feed successfully with valid RSS" do
    sign_in_user

    stub_successful_rss_parsing do
      assert_difference "Feed.count", 1 do
        assert_difference "Article.count", 1 do
          post feeds_url, params: { feed: { feed_url: "https://example.com/feed.xml" } }
        end
      end
    end

    assert_response :redirect
    assert_redirected_to articles_path
    assert_equal I18n.t("feeds.create.success"), flash[:notice]

    feed = Feed.last
    assert_equal @mock_feed_data[:title], feed.title
    assert_equal @mock_feed_data[:description], feed.description
    assert_equal @mock_feed_data[:feed_url], feed.feed_url
    assert_equal @user, feed.user
  end

  test "should create articles when creating feed" do
    sign_in_user

    stub_successful_rss_parsing do
      post feeds_url, params: { feed: { feed_url: "https://example.com/feed.xml" } }
    end

    feed = Feed.last
    article = feed.articles.last
    assert_equal feed, article.feed
    assert_equal @mock_feed_data[:entries].first[:title], article.title
    assert_equal @mock_feed_data[:entries].first[:content], article.content
  end

  test "should redirect with alert when RSS parsing fails" do
    sign_in_user

    stub_failed_rss_parsing do
      assert_no_difference "Feed.count" do
        assert_no_difference "Article.count" do
          post feeds_url, params: { feed: { feed_url: "https://invalid-feed.com" } }
        end
      end
    end

    assert_response :redirect
    assert_redirected_to new_feed_path
    assert_not_nil flash[:alert]
  end

  test "should require feed_url parameter" do
    sign_in_user

    post feeds_url, params: { feed: { title: "Invalid" } }

    assert_response :redirect
    assert_redirected_to new_feed_path
    assert_equal I18n.t("feeds.create.url_required"), flash[:alert]
  end

  # SHOW action tests
  test "should redirect unauthenticated user from show" do
    get feed_url(@feed)

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should show feed for authenticated user" do
    sign_in_user

    get feed_url(@feed)

    assert_response :success
    assert assigns(:feed)
    assert assigns(:articles)
    assert_equal @feed, assigns(:feed)
  end

  test "should not allow user to view other user's feeds" do
    sign_in_user_with_no_feeds
    other_feed = @user.feeds.first

    get feed_url(other_feed)

    # Should redirect to feeds path when user tries to access unauthorized feed
    assert_response :redirect
  end

  test "should show recent articles for feed" do
    sign_in_user

    get feed_url(@feed)

    assert_response :success
    articles = assigns(:articles)
    assert_not_nil articles
    # Verify articles belong to the feed
    articles.each do |article|
      assert_equal @feed, article.feed
    end
  end

  # DESTROY action tests
  test "should redirect unauthenticated user from destroy" do
    delete feed_url(@feed)

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should destroy feed for authenticated user" do
    sign_in_user

    assert_difference "Feed.count", -1 do
      delete feed_url(@feed)
    end

    assert_response :redirect
    assert_redirected_to feeds_path
    assert_not_nil flash[:notice]
  end

  test "should not allow user to destroy other user's feeds" do
    sign_in_user_with_no_feeds
    other_feed = @user.feeds.first

    delete feed_url(other_feed)

    # Should redirect when user tries to destroy unauthorized feed
    assert_response :redirect
  end

  test "should destroy associated articles when destroying feed" do
    sign_in_user
    feed_articles_count = @feed.articles.count

    assert_difference "Article.count", -feed_articles_count do
      delete feed_url(@feed)
    end
  end

  # Edge cases and error handling
  test "should handle invalid feed ID gracefully" do
    sign_in_user

    get feed_url(id: 99999)

    # Should handle invalid ID gracefully
    assert_response :redirect
  end

  test "should handle multiple feeds in index" do
    sign_in_user

    # Create additional feed
    additional_feed = @user.feeds.create!(
      title: "Additional Feed",
      feed_url: "https://example.com/additional.xml",
      site_url: "https://example.com",
      favicon: "https://example.com/favicon.ico"
    )

    get feeds_url

    assert_response :success
    feeds = assigns(:feeds)
    assert_includes feeds, @feed
    assert_includes feeds, additional_feed
    assert feeds.count >= 2
  end

  test "should show trash icon to feed owner in index" do
    sign_in_user

    get feeds_url

    assert_response :success
    assert_select "svg.icon-tabler-trash"
  end

  test "should only show trash icon for current user's feeds" do
    other_user = users(:two)
    other_feed = other_user.feeds.create!(
      title: "Other User Feed",
      feed_url: "https://other.com/feed.xml",
      site_url: "https://other.com",
      favicon: "https://other.com/favicon.ico"
    )

    sign_in_user

    get feeds_url
    assert_response :success
    assert_select "svg.icon-tabler-trash"
  end

  test "should not show trash icon to unauthenticated user viewing user profile" do
    get user_url(@user)

    assert_response :success
    assert_select "svg.icon-tabler-trash", count: 0
  end

  test "should show trash icon when authenticated user views their own profile" do
    sign_in_user

    get user_url(@user)

    assert_response :success
    assert_select "svg.icon-tabler-trash"
  end

  test "should not show trash icon when authenticated user views other user's profile" do
    sign_in_user_with_no_feeds
    other_user = @user

    get user_url(other_user)

    assert_response :success
    # Trash icon should NOT be visible for other user's feeds
    assert_select "svg.icon-tabler-trash", count: 0
  end
end
