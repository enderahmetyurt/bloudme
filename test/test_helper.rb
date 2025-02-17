ENV["RAILS_ENV"] ||= "test"

require "simplecov"
require_relative "../config/environment"
require "rails/test_help"
require "vcr"
SimpleCov.start

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def sign_in(user, password: "password")
      post session_url, params: { email_address: user.email_address, password: }
    end

    VCR.configure do |config|
      config.cassette_library_dir = "test/vcr_cassettes"
      config.hook_into :webmock
      config.filter_sensitive_data("<YOUTUBE_API_KEY>") { Rails.application.credentials.dig(:youtube, :api_key) }
    end
  end
end
