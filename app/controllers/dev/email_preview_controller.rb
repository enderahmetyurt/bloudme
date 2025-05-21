class Dev::EmailPreviewController < ApplicationController
  def confirmation
    user = User.first

    render template: "user_mailer/confirmation_email", layout: "mailer", locals: { user: user }
  end

  def reminder
    user = User.first
    user.update(confirmation_sent_at: Time.current)

    render template: "user_mailer/bloudme_email_confirmation_notice", layout: "mailer", locals: { user: user }
  end
end
