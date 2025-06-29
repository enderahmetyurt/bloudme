# app/controllers/lemonsqueezy_controller.rb
class LemonsqueezyController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token
  def webhook
    payload = request.raw_post
    signature = request.headers["X-Signature"]
    secret = "NAlmxO2YFuLgX"

    unless valid_signature?(payload, signature, secret)
      Rails.logger.warn("Geçersiz webhook imzası")
      return head :unauthorized
    end

    data = JSON.parse(payload)
    event = data.dig("meta", "event_name")

    case event
    when "subscription_created"
      handle_subscription_created(data)
    when "subscription_cancelled", "subscription_expired"
      handle_subscription_cancelled(data)
    else
      Rails.logger.info("Webhook event ignored: #{event}")
    end

    head :ok
  end

  private

  def valid_signature?(payload, signature, secret)
    expected_signature = OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
    ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
  end

  def handle_subscription_created(data)
    user_id = data.dig("meta", "custom_data", "user_id")
    return unless user_id

    user = User.find_by(id: user_id)
    return unless user

    user.update!(
      subscription_active: true,
      subscription_expires_at: 1.month.from_now
    )
  end

  def handle_subscription_cancelled(data)
    user_id = data.dig("meta", "custom_data", "user_id")
    return unless user_id

    user = User.find_by(id: user_id)
    return unless user

    user.update!(
      subscription_active: false,
      subscription_expires_at: nil
    )
  end
end
