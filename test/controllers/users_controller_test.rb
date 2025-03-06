require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @feeds = feeds(:one)
  end

  def sign_in_user
    sign_in_as(@user)
  end

  test "should redirect unauthenticated user from show" do
    get user_url(@user)

    assert_response :redirect
    assert_redirected_to new_session_path
    assert_nil assigns(:user)
    assert_nil assigns(:posts)
  end

  test "should show authenticated user and their feeds" do
    sign_in_user

    get user_url(@user)

    assert_response :success

    assert assigns(:user)
    assert assigns(:feeds)
  end
end
