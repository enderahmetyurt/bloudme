require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @feed = feeds(:one)
    @article = articles(:one)
    @unread_article = articles(:unread)
  end

  test "recent scope should order by published_at desc" do
    assert_equal Article.order(published_at: :desc), Article.recent
  end

  test "unread scope should return only unread articles" do
    assert_includes Article.unread, @unread_article
    assert_not_includes Article.unread, @article
  end

  test "by_current_user scope should return articles belonging to the user's feeds" do
    assert_includes Article.by_current_user(@user), @article
  end
end
