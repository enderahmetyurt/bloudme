require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @post = posts(:one)
  end

  test "post should be valid" do
    assert @post.valid?
  end

  test "post without title should be invalid" do
    @post.title = nil
    assert_not @post.valid?
    assert_includes @post.errors[:title], "can't be blank"
  end

  test "post with title longer than 100 characters should be invalid" do
    @post.title = "a" * 101
    assert_not @post.valid?
    assert_includes @post.errors[:title], "is too long (maximum is 100 characters)"
  end

  test "post without content should be invalid" do
    @post.content = nil
    assert_not @post.valid?
    assert_includes @post.errors[:content], "can't be blank"
  end

  test "post with content longer than 400 characters should be invalid" do
    @post.content = "a" * 401
    assert_not @post.valid?
    assert_includes @post.errors[:content], "is too long (maximum is 400 characters)"
  end

  test "post should belong to a user" do
    assert_equal @user, @post.user
  end

  test "published scope should return only published posts" do
    published_posts = Post.published
    assert_includes published_posts, posts(:published)
    assert_not_includes published_posts, posts(:unpublished)
  end
end
