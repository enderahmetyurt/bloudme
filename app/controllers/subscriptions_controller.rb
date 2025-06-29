# app/controllers/subscriptions_controller.rb
class SubscriptionsController < ApplicationController
  def create
    url = LemonCheckoutCreator.new(Current.user).call
    redirect_to url, allow_other_host: true
  rescue => e
    Rails.logger.error("Checkout oluşturulamadı: #{e.message}")
    redirect_to root_path, alert: "Abonelik başlatılamadı. Lütfen tekrar deneyin."
  end

def thank_you
  return if Current.user.present?

  user = User.find_by(id: params[:user_id], session_token: params[:token])
  if user
    session[:user_id] = user.id
    flash[:notice] = "Hoş geldin, aboneliğin aktif!"
  else
    flash[:alert] = "Giriş yapılamadı. Lütfen tekrar deneyin."
    redirect_to new_user_session_path
  end
end
end
