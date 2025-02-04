require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "email should be present" do
    @user.email_address = " "
    assert_not @user.valid?
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email_address = @user.email_address.upcase
    assert_not duplicate_user.valid?
  end

  test "email should be normalized" do
    @user.email_address = "  TEST@Example.com "
    @user.save
    assert_equal "test@example.com", @user.reload.email_address
  end

  test "password should be secure" do
    assert @user.authenticate("password")
    assert_not @user.authenticate("wrongpassword")
  end

  test "avatar_url should be set on create" do
    user = User.create(email_address: "newuser@example.com", password: "password")
    assert user.avatar_url.present?
    assert_match(/#{User::DICE_BEAR_URL}/, user.avatar_url)
  end

  test "nick_name should be set on create" do
    user = User.create(email_address: "newuser@example.com", password: "password")
    assert_equal "newuser", user.nick_name
  end
end
