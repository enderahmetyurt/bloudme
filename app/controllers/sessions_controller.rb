class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :resume_session, only: [ :new ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    redirect_to root_url if authenticated?
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      if !user.email_confirmed? && user.confirmation_expired?
        redirect_to new_session_path, alert: "Email onay süreniz dolmuş. Lütfen yeniden onay maili isteyin."
      elsif !user.email_confirmed?
        redirect_to new_session_path, alert: "Email adresiniz henüz onaylanmamış."
      else
        start_new_session_for user
        redirect_to after_authentication_url, notice: t("home.signed_in")
      end
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end


  def destroy
    terminate_session
    redirect_to new_session_url, notice: t("home.signed_out")
  end
end
