class Users::ConfirmationsController < ApplicationController
  def show
    user = User.find_by(confirmation_token: params[:token])

    if user && !user.confirmation_expired?
      user.confirm_email!
      redirect_to root_path, notice: t("home.email_confirmed")
    else
      redirect_to root_path, alert: t("home.email_cannot_confirmed")
    end
  end

  def resend_confirmation
    user = Current.user
    user.generate_confirmation_token
    user.save(validate: false)

    if user && !user.email_confirmed? && !user.confirmation_expired?
      if ResendMailer.send_email(
          to: user.email_address,
          subject: "Please confirm your email address",
          html: render_to_string(
            layout: "layouts/mailer",
            template: "user_mailer/confirmation_email",
            locals: { user: user }
          )
        )
        redirect_to root_path, notice: t("home.confirmation_email")
      else
        redirect_to root_path, alert: t("home.confirmation_email_failed")
      end
    else
      redirect_to root_path, alert: t("home.email_cannot_resend_confirmation")
    end
  end
end
