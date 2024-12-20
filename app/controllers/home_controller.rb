class HomeController < ApplicationController
  layout "home"
  allow_unauthenticated_access
  def index
    redirect_to posts_path if authenticated?
  end
end
