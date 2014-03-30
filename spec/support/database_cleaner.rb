#vhttp://stackoverflow.com/questions/12326096/capybara-selenium-fault-and-redirect-example-com-when-without-everything-is-gre

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before :each do
    if Capybara.current_driver == :rack_test
      DatabaseRewinder.strategy = :transaction
    else
      DatabaseRewinder.strategy = :truncation
    end
    DatabaseRewinder.start
  end

  config.after do
    DatabaseRewinder.clean
    Sunspot.remove_all!
  end
end
