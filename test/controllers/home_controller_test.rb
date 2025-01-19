require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to posts path when authenticated" do
    user = users(:one)
    sign_in(user, password: "password")

    get root_url

    assert_redirected_to articles_path
  end

  test "should render index template when not authenticated" do
    get root_url

    assert_response :success
    assert_template :index
  end

  test "should use the 'home' layout when not authenticated" do
    get root_url

    assert_template layout: "home"
  end
end
