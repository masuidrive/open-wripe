=begin
Stopped to use 'poltergeist' for headless test.
because I can't resolve below.

Poltergeist detected another element with CSS selector 'html body.phone div.modal-backdrop.fade.in' at this position. It may be overlapping the element you are trying to interact with. If you don't care about overlapping elements, try using node.trigger('click').
=end

Capybara.register_driver :selenium_chrome_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument('--headless')
    opts.add_argument('--disable-gpu') if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.add_argument('--disable-site-isolation-trials')
    opts.add_argument('--no-sandbox')
  end

  Capybara::Selenium::Driver.new(app, **{ :browser => :chrome, options_key => browser_options })
end

Capybara.register_driver :safari do |app|
  Capybara::Selenium::Driver.new(app, browser: :safari)
end

Capybara.register_driver :iphone do |app|
  Capybara.default_max_wait_time = 30
  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://127.0.0.1:4723/wd/hub",
    desired_capabilities: {
      browserName: 'iphone',
      platform: 'Mac',
      version: '6.1',
      app: 'safari'
    }
end

Capybara.register_driver :ipad do |app|
  Capybara.default_max_wait_time = 30
  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://127.0.0.1:4723/wd/hub",
    desired_capabilities: {
      browserName: 'ipad',
      platform: 'Mac',
      version: '6.1',
      app: 'safari',
      deviceOrientation: 'landscape'
    }
end

Capybara.register_driver :android do |app|
  Capybara.default_max_wait_time = 30
  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://127.0.0.1:4723/wd/hub",
    desired_capabilities: {
      browserName: 'android',
      platform: 'Mac',
      version: '2.3',
      app: 'safari',
      deviceOrientation: 'landscape'
    }
end

Capybara.register_driver :phone do |app|
  Capybara::Selenium::Driver.new(app)
end

Capybara.register_driver :tablet do |app|
  Capybara::Selenium::Driver.new(app)
end

if %i(iphone ipad phone tablet ios android).include?(Capybara.javascript_driver)
  $el = {
    edit_title: '#edit-page-title-phone',
    edit_body: '#edit-page-body-phone',
    edit_save: '#edit-page-save-phone'
  }
  RSpec.configure do |config|
    config.before :each do

    end
  end
else
  $el = {
    edit_title: '#edit-page-title',
    edit_body: '#edit-page-body',
    edit_save: '#edit-page-save'
  }
end