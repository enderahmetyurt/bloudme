class HomeController < ApplicationController
  layout "home"
  allow_unauthenticated_access
  def index; end
end
