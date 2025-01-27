require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  def sign_in_user
    sign_in @user
  end

  test "should redirect unauthenticated user from show" do
    get user_url(@user)

    assert_response :redirect
    assert_redirected_to new_session_path
    assert_nil assigns(:user)
    assert_nil assigns(:posts)
  end
end
