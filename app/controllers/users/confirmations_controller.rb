class Users::ConfirmationsController < ApplicationController
  def show
    user = User.find_by(confirmation_token: params[:token])

    if user && !user.confirmation_expired?
      user.confirm_email!
      redirect_to root_path, notice: "Email adresiniz onaylandı."
    else
      redirect_to root_path, alert: "Geçersiz veya süresi dolmuş onay bağlantısı."
    end
  end
end
