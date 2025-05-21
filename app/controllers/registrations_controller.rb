class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :resume_session, only: :new
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    redirect_to root_url, notice: t("already_signed_in") if authenticated?
  end

  def create
    user = User.new(params.permit(:email_address, :password))

    if user.save
      start_new_session_for user

      ResendMailer.send_email(
        to: user.email_address,
        subject: "Email adresinizi onaylayın",
        html: render_to_string(
          template: "user_mailer/confirmation_email",
          locals: { user: user }
        )
      )

      redirect_to after_authentication_url, notice: t("home.sign_up") # TODO: "Kaydınız alındı. Lütfen email adresinizi onaylayın."
    else
      redirect_to new_registration_url(email_address: params[:email_address]), alert: user.errors.full_messages.to_sentence
    end
  end
end
