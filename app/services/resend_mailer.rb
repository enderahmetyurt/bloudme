require "net/http"
require "uri"
require "json"

class ResendMailer
  def self.send_email(to:, subject:, html:)
    uri = URI.parse("https://api.resend.com/emails")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      "Authorization" => "Bearer #{Rails.application.credentials.dig(:resend, :api_key)}",
      "Content-Type" => "application/json"
    })

    request.body = {
      from: "Bloudme <no-reply@bloud.me>",
      to: to,
      subject: subject,
      html: html
    }.to_json

    response = http.request(request)
    Rails.logger.info "Resend Email Response: #{response.code} - #{response.body}"

    response.code == "200" || response.code == "202"
  end
end
