require 'spec_helper'

def signout_github
  visit 'https://github.com/logout'
  if page.has_css?('.auth-form-body .button')
    find('.auth-form-body .button').click
    wait_until(10) do
      current_path == '/'
    end
  end
end

feature 'GitHub', :js => true do
  scenario 'signin' do
    if %i(safari selenium).include?(Capybara.javascript_driver)
      pending "#{Capybara.javascript_driver} doesn't support this test"
    else
      signout_github

      visit '/'
      find('#signin-github').click

      wait_until do
        page.has_xpath?("//input[@name='login_field']|//input[@name='login']")
      end

      test_user = GhAuth.config['tests'].first
      find(:xpath, "//input[@name='login_field']|//input[@name='login']").set test_user['email']
      find(:xpath, "//input[@name='password']|//input[@name='password']").set test_user['password']
      find(:xpath, "//input[@name='commit']|//button[@type='submit']").click

      wait_until_visible('#nav-username-link')

      expect(current_path).to eq '/app'
      expect(evaluate_script('session.username()')).to eq test_user['account']
      user = User.find_by_email test_user['email']
      expect(user.pages).to must_be_empty
    end
  end
end
