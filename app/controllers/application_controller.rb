class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :set_locale
  allow_browser versions: :modern

  def set_locale
    if params[:locale].present?
      session[:locale] = params[:locale]
    end

    user_locale = Current.user&.preferred_locale
    session[:locale] = "en" if session[:locale] == "se"
    I18n.locale = (user_locale.presence || session[:locale] || I18n.default_locale)
  end
end
