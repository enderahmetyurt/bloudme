class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@bloud.me"

  layout "mailer"

  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end
end
