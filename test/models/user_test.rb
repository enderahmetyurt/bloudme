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

  test "confirmation token should be generated on create" do
    user = User.create(email_address: "newuser@example.com", password: "password")
    assert user.confirmation_token.present?
    assert user.confirmation_sent_at.present?
  end

  test "session token should be generated on create" do
    user = User.create(email_address: "newuser@example.com", password: "password")
    assert user.session_token.present?
  end

  test "confirm_email! should update user" do
    @user.email_confirmed = false
    @user.confirmation_token = "test_token"
    @user.confirmation_sent_at = Time.current
    @user.save

    @user.confirm_email!

    assert @user.email_confirmed
    assert_nil @user.confirmation_token
    assert_nil @user.confirmation_sent_at
  end

  test "confirmation_expired? should return true when expired" do
    @user.confirmation_sent_at = 8.days.ago
    assert @user.confirmation_expired?
  end

  test "confirmation_expired? should return false when not expired" do
    @user.confirmation_sent_at = 6.days.ago
    assert_not @user.confirmation_expired?
  end

  test "confirmation_expired? should return false when confirmation_sent_at is nil" do
    @user.confirmation_sent_at = nil
    assert_not @user.confirmation_expired?
  end

  test "login_blocked_reason should return nil when email confirmed and not expired" do
    @user.email_confirmed = true
    @user.confirmation_sent_at = 6.days.ago
    assert_nil @user.login_blocked_reason
  end

  test "login_blocked_reason should return message when email not confirmed" do
    @user.email_confirmed = false
    assert_equal "Email unconfirmed", @user.login_blocked_reason
  end

  test "login_blocked_reason should return message when confirmation expired" do
    @user.email_confirmed = true
    @user.confirmation_sent_at = 8.days.ago
    assert_equal "Email confirmation expired", @user.login_blocked_reason
  end
end
