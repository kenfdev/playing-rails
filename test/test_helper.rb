# typed: false

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "factory_bot_rails"
require "webmock/minitest"
require "vcr"
require "database_cleaner/active_record"
require_relative "test_helpers/session_test_helper"

VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join("test/vcr_cassettes").to_s
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = false
  c.ignore_localhost = true
end

DatabaseCleaner.allow_remote_database_url = true
DatabaseCleaner.strategy = :transaction

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include FactoryBot::Syntax::Methods
  end
end
