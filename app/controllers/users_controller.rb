class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @feeds = @user.feeds
  end
end
