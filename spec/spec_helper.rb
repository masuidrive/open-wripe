# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'sunspot/rails/spec_helper'

FactoryBot.find_definitions

ActiveSupport::Deprecation.behavior = :silence

require 'capybara/rspec'
Capybara.server_port = 57124
Capybara.default_max_wait_time = 10

# Capybara.javascript_driver = :selenium, :chrome or :safari
Capybara.javascript_driver = ENV['DRIVER'] ? ENV['DRIVER'].to_sym : :chrome

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

$original_sunspot_session = ::Sunspot.session

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by Capybara.javascript_driver
  end

  # database_cleaner
  config.before :suite do
    #DatabaseRewinder.clean_all
    DatabaseRewinder.strategy = :truncation
    DatabaseRewinder.clean_with :truncation
  end

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before :each, :solr => true do
    ::Sunspot.session = ::Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)
  end

  config.after(:each) do
    ::Sunspot.session = $original_sunspot_session
    DatabaseRewinder.clean
  end
end
