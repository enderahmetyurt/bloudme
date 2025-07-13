require "test_helper"

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @user_with_no_bookmarks = users(:two)
    @article = articles(:one)
    @bookmark = bookmarks(:one)
  end

  def sign_in_user
    sign_in_as(@user)
  end

  def sign_in_user_with_no_bookmarks
    sign_in_as(@user_with_no_bookmarks)
  end

  test "should redirect unauthenticated user from index" do
    get bookmarks_url

    assert_response :redirect
    assert_redirected_to new_session_path
  end

  test "should show bookmarks index for authenticated user" do
    sign_in_user

    get bookmarks_url

    assert_response :success
    assert assigns(:articles)
  end

  test "should only show bookmarked articles for current user" do
    sign_in_user

    get bookmarks_url

    assert_response :success
    articles = assigns(:articles)
    assert_not_nil articles

    # Verify that all returned articles are bookmarked by the current user
    articles.each do |article|
      assert Bookmark.exists?(user: @user, article: article)
    end
  end

  test "should show empty collection when user has no bookmarks" do
    sign_in_user_with_no_bookmarks
    Bookmark.where(user: @user_with_no_bookmarks).destroy_all

    get bookmarks_url

    assert_response :success
    articles = assigns(:articles)
    assert_not_nil articles
    assert_equal 0, articles.count
  end

  test "should handle large number of bookmarks" do
    sign_in_user

    # Create additional articles and bookmarks for testing
    10.times do |i|
      article = Article.create!(
        title: "Test Article #{i}",
        content: "Test content",
        link: "http://example.com/#{i}",
        feed: @article.feed,
        published_at: Time.current
      )
      Bookmark.create!(user: @user, article: article)
    end

    get bookmarks_url

    assert_response :success
    articles = assigns(:articles)
    assert_not_nil articles
    assert articles.count >= 1
  end
end
