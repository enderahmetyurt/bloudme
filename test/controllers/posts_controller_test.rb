require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:one)
  end

  # Helper method for authenticating the user
  def sign_in_user
    sign_in @user
  end

  # Helper method to assert unauthenticated access
  def assert_unauthenticated_access(path, method = :get, params = {})
    send(method, path, params: params)
    assert_redirected_to new_session_path
  end

  test "should get index as authenticated user" do
    sign_in_user
    get posts_url
    assert_response :success
  end

  test "should not get index as unauthenticated user" do
    assert_unauthenticated_access(posts_url)
  end

  test "should get new as authenticated user" do
    sign_in_user
    get new_post_url
    assert_response :success
  end

  test "should not get new as unauthenticated user" do
    assert_unauthenticated_access(new_post_url)
  end

  test "should create post as authenticated user" do
    sign_in_user
    assert_difference("Post.count") do
      post posts_url, params: {
        post: {
          title: "New Post",
          content: "<p>This is a <strong>rich</strong> text content.</p>",
          user_id: @user.id,
          published: true
        }
      }
    end
    assert_redirected_to post_url(Post.last)
  end

  test "should not create post as unauthenticated user" do
    assert_unauthenticated_access(posts_url, :post, post: { title: "New Post", content: "<p>Text</p>", user_id: @user.id, published: true })
  end

  test "should not create post with invalid data as unauthenticated user" do
    assert_unauthenticated_access(posts_url, :post, post: { title: "", content: "<p>Invalid Post</p>", user_id: @user.id, published: true })
  end

  test "should show post as authenticated user" do
    sign_in_user
    get post_url(@post)
    assert_response :success
  end

  test "should not show post as unauthenticated user" do
    assert_unauthenticated_access(post_url(@post))
  end

  test "should get edit as authenticated user" do
    sign_in_user
    get edit_post_url(@post)
    assert_response :success
  end

  test "should not get edit as unauthenticated user" do
    assert_unauthenticated_access(edit_post_url(@post))
  end

  test "should update post as authenticated user" do
    sign_in_user
    patch post_url(@post), params: {
      post: {
        title: "Updated Title",
        content: "<p>Updated <em>rich</em> text content.</p>",
        user_id: @user.id,
        published: false
      }
    }
    assert_redirected_to post_url(@post)
  end

  test "should not update post as unauthenticated user" do
    assert_unauthenticated_access(post_url(@post), :patch, post: { title: "Updated", content: "<p>Text</p>", user_id: @user.id, published: false })
  end

  test "should destroy post as authenticated user" do
    sign_in_user
    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end
    assert_redirected_to posts_url
  end

  test "should not destroy post as unauthenticated user" do
    assert_unauthenticated_access(post_url(@post), :delete)
  end
end
