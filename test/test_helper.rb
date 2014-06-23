ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  include SessionsHelper

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def setup
    sign_in users(:one) if defined? session
  end
end

class ActionController::TestCase
  include SessionsHelper
end

class ActionDispatch::IntegrationTest
  fixtures :users, :microposts

  def sign_in(user)
    post_via_redirect sessions_path, { email: user.email, password: user.password }
  end

  def assert_error_message(message)
    assert_select 'div.alert.alert-error', message
  end

  def assert_success(message)
    assert_select 'div.alert.alert-success', message
  end

end
