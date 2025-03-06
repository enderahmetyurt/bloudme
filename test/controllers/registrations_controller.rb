require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_params = { email_address: "user@example.com", password: "password" }
    @user = users(:one)
  end

  test "should get new when not authenticated" do
    get new_registration_path
    assert_response :success
  end

  test "should redirect to root when authenticated" do
    sign_in_as(user)
    get new_registration_path
    assert_redirected_to root_url
    assert_equal "You are already signed in.", flash[:notice]
  end

  test "should create user and start new session" do
    assert_difference "User.count", 1 do
      post registration_url, params: @user_params
    end
    assert_redirected_to posts_path
    assert_equal "Signed up.", flash[:notice]
  end

  test "should not create user and redirect to new registration with error" do
    user_params = { email_address: "invalid", password: "short" }
    post registration_url, params: user_params
    assert_redirected_to new_registration_path(email_address: "invalid")
    assert_not_empty flash[:alert]
  end

  test "should rate limit registration attempts" do
    10.times do
      post registration_url, params: { user: @user_params }
    end
    post registration_url, params: { user: @user_params }
    assert_redirected_to new_registration_path
    assert_equal "Password can't be blank, Email address can't be blank, and Email address is invalid", flash[:alert]
  end
end
