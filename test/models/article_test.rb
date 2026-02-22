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

  test "unread_for_user scope should return only unread articles for user" do
    user_two = users(:two)
    assert_includes Article.unread_for_user(user_two), @unread_article
    assert_not_includes Article.unread_for_user(user_two), articles(:two)
  end

  test "for_user scope should return articles belonging to the user" do
    assert_includes Article.for_user(@user), @article
  end
end
