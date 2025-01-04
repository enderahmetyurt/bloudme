class DashboardController < ApplicationController
  def index
    @posts =  Current.user.posts
  end
end
