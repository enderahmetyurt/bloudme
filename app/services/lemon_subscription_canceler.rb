# app/services/lemon_subscription_canceler.rb
class LemonSubscriptionCanceler
  LEMONSQUEEZY_API_KEY = Rails.application.credentials.dig(:lemonsqueezy, :api_key)

  def self.call(subscription_id)
    uri = URI("https://api.lemonsqueezy.com/v1/subscriptions/#{subscription_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    headers = {
      "Authorization" => "Bearer #{LEMONSQUEEZY_API_KEY}",
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    body = {
      data: {
        type: "subscriptions",
        id: subscription_id,
        attributes: {
          cancelled: true
        }
      }
    }

    request = Net::HTTP::Patch.new(uri, headers)
    request.body = body.to_json

    response = http.request(request)
    json = JSON.parse(response.body)

    if response.code == "200"
      { success: true, data: json }
    else
      { success: false, error: json["errors"] || "Bilinmeyen hata" }
    end
  rescue => e
    { success: false, error: e.message }
  end
end
