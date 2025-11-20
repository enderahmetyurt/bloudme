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

  test "should show settings page for authenticated user" do
    sign_in_user

    get settings_user_path(@user)

    assert_response :success
    assert_select "form.user"
    assert_match(/Select language|Language/i, response.body)
  end

  test "should update preferred locale via settings" do
    sign_in_user

    patch user_path(@user), params: { user: { preferred_locale: "tr" } }

    assert_response :redirect
    assert_redirected_to user_path(@user)
    @user.reload
    assert_equal "tr", @user.preferred_locale
  end

  test "should display Turkish UI when user prefers Turkish" do
    sign_in_user
    @user.update(preferred_locale: "tr")

    get articles_path

    assert_response :success
    assert_match(/Ara/i, response.body)
  end
end
