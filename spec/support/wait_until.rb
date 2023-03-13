def wait_until(time=Capybara.default_max_wait_time)
  require "timeout"
  Timeout.timeout(time) do
    sleep(0.1) until yield
  end
  yield if block_given?
end

def wait_until_visible(selector, time=Capybara.default_max_wait_time)
  wait_until(time) do
    page.has_selector?(selector, visible: true)
  end
end

def wait_and_find_css(selector, time=Capybara.default_max_wait_time)
  wait_until(time) do
    page.has_css?(selector)
  end
  find(selector)
end
alias wait_and_find wait_and_find_css

def wait_and_find_xpath(selector, time=Capybara.default_max_wait_time)
  wait_until(time) do
    page.has_xpath?(selector)
  end
  find(:xpath, selector)
end
