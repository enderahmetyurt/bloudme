class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])

    if @user != Current.user
      redirect_to root_path, alert: t("users.show.alert")
    end

    @feeds = @user.feeds.recent
  end

  def settings
    @user = User.find(params[:id])

    if @user != Current.user
      redirect_to root_path, alert: t("users.show.alert")
    end
  end

  def update
    @user = User.find(params[:id])

    if @user != Current.user
      redirect_to root_path, alert: t("users.show.alert")
    end

    if @user.update(user_params)
      redirect_to settings_user_path(@user), notice: t("users.update.notice")
    else
      render :settings
    end
  end

  private
  def user_params
    params.require(:user).permit(:nick_name, :email, :password, :password_confirmation)
  end
end
