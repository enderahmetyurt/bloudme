class Users::ConfirmationsController < ApplicationController
  def show
    user = User.find_by(confirmation_token: params[:token])

    if user && !user.confirmation_expired?
      user.confirm_email!
      redirect_to root_path, notice: t("home.email_confirmed")
    else
      redirect_to root_path, alert: t("home.email_cannot_confirmed")
      # TODO: yenisini almak için tıklayınızı göstermek gerek
    end
  end
end
