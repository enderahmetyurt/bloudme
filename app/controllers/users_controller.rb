class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :settings, :update ]

  def show
    @feeds = @user.feeds.recent
  end

  def settings
    if @user != Current.user
      redirect_to root_path, alert: t("users.show.alert")
    end
  end

  def update
    if @user != Current.user
      redirect_to root_path, alert: t("users.show.alert")
    end

    if @user.update(user_params)
      I18n.locale = @user.preferred_locale
      redirect_to @user, notice: t("users.update.notice")
    else
      render :settings
    end
  end

  private

  def set_user
    @user = User.find_by!(nick_name: params[:id])
  end

  def user_params
    params.require(:user).permit(:nick_name, :email_address, :preferred_locale, :password, :password_confirmation, :twitter, :bsky, :github, :linkedin, :mastodon, :website, :bio, :full_name)
  end
end
