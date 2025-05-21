class UserMailerPreview < ActionMailer::Preview
  def confirmation_email
    user = User.first
    ApplicationController.render(
      template: "user_mailer/confirmation_email",
      layout: "mailer",
      assigns: { user: user }
    )
  end
end
