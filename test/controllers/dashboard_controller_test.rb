require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @posts = [
      posts(:one),
      posts(:one_1)
    ]
  end

  def sign_in_user
    sign_in @user
  end

  def assert_unauthenticated_access(path, method = :get, params = {})
    send(method, path, params: params)
    assert_redirected_to new_session_path
  end

  test "should not get index as unauthenticated user" do
    assert_unauthenticated_access(posts_url)
  end

  test "should get index and assign @posts" do
    sign_in_user
    get dashboard_index_url

    assert_response :success
    assert_equal 2, assigns(:posts).count
  end
end
