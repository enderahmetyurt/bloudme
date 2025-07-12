require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @user_with_no_feeds = users(:two)
    @feed = feeds(:one)
    @article = articles(:one)
    @unread_article = articles(:unread)
  end

  def sign_in_user
    sign_in_as(@user)
  end

  def sign_in_user_with_no_feeds
    sign_in_as(@user_with_no_feeds)
  end

  test "should redirect unauthenticated user from index" do
    get articles_url

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should redirect to new feed path when user has no feeds" do
    @user_with_no_feeds.feeds.destroy_all
    sign_in_user_with_no_feeds

    get articles_url

    assert_response :redirect
    assert_redirected_to new_feed_path
  end

  test "should show articles index with default unread filter" do
    sign_in_user

    get articles_url

    assert_response :success
    assert assigns(:articles)
  end

  test "should filter articles by read status" do
    sign_in_user

    get articles_url, params: { read: true }

    assert_response :success
    assert assigns(:articles)
  end

  test "should handle pagination" do
    sign_in_user

    get articles_url, params: { page: 2 }

    assert_response :success
    assert assigns(:articles)
  end

  test "should redirect unauthenticated user from show" do
    get article_url(@article)

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should show article and mark as read" do
    sign_in_user
    @unread_article.update(is_read: false)
    assert_not @unread_article.is_read

    get article_url(@unread_article)

    assert_response :success
    assert assigns(:article)
    @unread_article.reload
    assert @unread_article.is_read
  end

  test "should redirect unauthenticated user from search" do
    get search_articles_url, params: { query: "test" }

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should search articles" do
    sign_in_user

    get search_articles_url, params: { query: "test" }

    assert_response :success
    assert assigns(:query)
    assert assigns(:articles)
    assert_equal "test", assigns(:query)
  end

  test "should redirect unauthenticated user from update_read" do
    patch update_read_article_url(@article), params: { article: { read: true } }

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should update article read status via turbo stream" do
    sign_in_user

    patch update_read_article_url(@article), params: { article: { read: true } }, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    @article.reload
    assert @article.is_read
  end

  test "should update article read status via html" do
    sign_in_user

    patch update_read_article_url(@article), params: { article: { read: true } }

    assert_response :redirect
    assert_redirected_to articles_path
    assert_equal "Updated todo status.", flash[:notice]
    @article.reload
    assert @article.is_read
  end

  test "should redirect unauthenticated user from update_bookmark" do
    patch update_bookmark_article_url(@article), params: { article: { bookmarked: true } }

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should create bookmark via turbo stream" do
    sign_in_user
    Bookmark.where(article: @article, user: @user).destroy_all

    assert_difference "Bookmark.count", 1 do
      patch update_bookmark_article_url(@article), params: { article: { bookmarked: true } }, headers: { "Accept" => "text/vnd.turbo-stream.html", "HTTP_REFERER" => "http://example.com/articles" }
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    assert Bookmark.exists?(article: @article, user: @user)
  end

  test "should destroy bookmark via turbo stream" do
    sign_in_user
    assert Bookmark.exists?(article: @article, user: @user)

    assert_difference "Bookmark.count", -1 do
      patch update_bookmark_article_url(@article), params: { article: { bookmarked: false } }, headers: { "Accept" => "text/vnd.turbo-stream.html", "HTTP_REFERER" => "http://example.com/articles" }
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
    assert_not Bookmark.exists?(article: @article, user: @user)
  end

  test "should create bookmark via html" do
    sign_in_user
    Bookmark.where(article: @article, user: @user).destroy_all

    assert_difference "Bookmark.count", 1 do
      patch update_bookmark_article_url(@article), params: { article: { bookmarked: true } }
    end

    assert_response :redirect
    assert_redirected_to bookmarks_path
    assert_equal "Updated bookmarked.", flash[:notice]
    assert Bookmark.exists?(article: @article, user: @user)
  end

  test "should destroy bookmark via html" do
    sign_in_user
    assert Bookmark.exists?(article: @article, user: @user)

    assert_difference "Bookmark.count", -1 do
      patch update_bookmark_article_url(@article), params: { article: { bookmarked: false } }
    end

    assert_response :redirect
    assert_redirected_to bookmarks_path
    assert_equal "Updated bookmarked.", flash[:notice]
    assert_not Bookmark.exists?(article: @article, user: @user)
  end

  test "should handle turbo stream bookmark removal from bookmarks page" do
    sign_in_user
    assert Bookmark.exists?(article: @article, user: @user)

    patch update_bookmark_article_url(@article),
          params: { article: { bookmarked: false } },
          headers: {
            "Accept" => "text/vnd.turbo-stream.html",
            "HTTP_REFERER" => "http://example.com/bookmarks"
          }

    assert_response :success
    assert_match /turbo-stream.*remove/, response.body
  end
end
