class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])

    if @user != Current.user
      redirect_to root_path, alert: t("users.show.alert")
    end

    @feeds = @user.feeds.recent
  end
end
