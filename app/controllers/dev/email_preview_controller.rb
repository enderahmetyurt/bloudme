class Dev::EmailPreviewController < ApplicationController
  def confirmation
    user = User.first
    render template: "user_mailer/confirmation_email", layout: "mailer", locals: { user: user }
  end
end
