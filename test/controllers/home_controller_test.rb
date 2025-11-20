require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to posts path when authenticated" do
    user = users(:one)
    sign_in_as(user)

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

  test "should handle locale parameter when not authenticated" do
    get root_url, params: { locale: "tr" }

    assert_response :success
    assert_template :index
    assert_template layout: "home"
    assert_equal "tr", session[:locale]
  end

  test "should allow unauthenticated access" do
    get root_url

    assert_response :success
    assert_no_match(/redirect/i, response.body)
  end

  test "should handle multiple consecutive requests correctly" do
    3.times do
      get root_url
      assert_response :success
      assert_template :index
      assert_template layout: "home"
    end
  end

  test "should maintain session state across multiple requests" do
    user = users(:one)
    sign_in_as(user)

    3.times do
      get root_url
      assert_redirected_to articles_path
    end
  end
end
