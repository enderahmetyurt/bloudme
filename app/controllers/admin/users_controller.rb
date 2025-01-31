class Admin::UsersController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def show
    @user = User.find(params[:id])
    @feeds = @user.feeds
  end

  private

  def authenticate_admin!
    unless Current.user&.is_admin?
      redirect_to root_path, alert: "You are not authorized to access this page"
    end
  end
end
