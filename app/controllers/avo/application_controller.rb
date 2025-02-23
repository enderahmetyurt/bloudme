module Avo
  class ApplicationController < BaseApplicationController
    include Authentication
    delegate :new_session_path, to: :main_app

    # we are prepending the action to ensure it will be fired very early on in the request lifecycle
    prepend_before_action :require_authentication
  end
end
