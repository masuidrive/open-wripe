require 'spec_helper'

def signout_facebook
  visit 'https://www.facebook.com/'
  if page.has_css?('#userNavigationLabel')
    find('#userNavigationLabel').click
    find("#logout_form input[type='submit']").click
    wait_until do # until back to top
      page.has_css?('#email')
    end
  end
end

feature 'Facebook', :js => true do
  scenario 'signin' do
    signout_facebook

    visit '/'
    find('#signin-facebook').click

    wait_until do
      page.has_xpath?("//input[@name='email']")
    end

    test_user = FbAuth.config['tests'].first
    find(:xpath, "//input[@name='email']").set test_user['email']
    find(:xpath, "//input[@name='pass']").set test_user['password']
    find(:xpath, "//input[@name='login']|//button[@name='login']").click

    wait_until_visible('#nav-username-link')
    
    expect(current_path).to eq '/app'
    expect(evaluate_script('session.username()')).to eq test_user['account']
    user = User.find_by_email test_user['email']
    expect(user.pages).to must_be_empty
  end
end
