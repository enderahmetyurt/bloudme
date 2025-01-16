require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @published_post = posts(:published)
    @unpublished_post = posts(:unpublished)
  end

  def sign_in_user
    sign_in @user
  end

  test "should get show and assign correct user and posts for authenticated user" do
    sign_in_user

    get user_url(@user)

    assert_response :success
    assert_equal assigns(:user), @user
    assert_includes assigns(:posts), @published_post
    assert_not_includes assigns(:posts), @unpublished_post
  end

  test "should redirect unauthenticated user from show" do
    get user_url(@user)

    assert_response :redirect
    assert_redirected_to new_session_path
    assert_nil assigns(:user)
    assert_nil assigns(:posts)
  end
end
