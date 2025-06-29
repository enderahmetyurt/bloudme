# app/services/lemon_checkout_creator.rb
require "net/http"
require "json"

class LemonCheckoutCreator
  ENDPOINT = URI("https://api.lemonsqueezy.com/v1/checkouts")
  LEMONSQUEEZY_API_KEY = Rails.application.credentials.dig(:lemonsqueezy, :api_key)
  LEMONSQUEEZY_STORE_ID = Rails.application.credentials.dig(:lemonsqueezy, :store_id)
  LEMONSQUEEZY_VARIANT_ID = Rails.application.credentials.dig(:lemonsqueezy, :variant_id)
  LEMONSQUEEZY_REDIRECT_URL = Rails.application.credentials.dig(:lemonsqueezy, :redirect_url)

  def initialize(user)
    @user = user
  end

  def call
    http = Net::HTTP.new(ENDPOINT.host, ENDPOINT.port)
    http.use_ssl = true
    redirect_url = "#{Rails.application.credentials.dig(:lemonsqueezy, :redirect_url)}?user_id=#{@user.id}&token=#{@user.session_token}"

    headers = {
      "Authorization" => "Bearer #{LEMONSQUEEZY_API_KEY}",
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    body = {
      data: {
        type: "checkouts",
        attributes: {
          checkout_data: {
            email: @user.email_address,
            custom: {
              user_id: @user.id.to_s
            }
          },
          product_options: {
            redirect_url: redirect_url
          }
        },
        relationships: {
          store:   { data: { type: "stores", id: LEMONSQUEEZY_STORE_ID } },
          variant: { data: { type: "variants", id: LEMONSQUEEZY_VARIANT_ID } }
        }
      }
    }

    req = Net::HTTP::Post.new(ENDPOINT, headers)
    req.body = body.to_json
    response = http.request(req)
    json = JSON.parse(response.body)

    json["data"]["attributes"]["url"]
  end
end
