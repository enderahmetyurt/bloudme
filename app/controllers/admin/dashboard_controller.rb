class Admin::DashboardController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @users = User.all
  end

  private

  def authenticate_admin!
    unless Current.user&.is_admin?
      redirect_to root_path, alert: "You are not authorized to access this page"
    end
  end
end
