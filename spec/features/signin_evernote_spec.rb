require 'rails_helper'

def signout_evernote
  visit 'https://sandbox.evernote.com/Logout.action'
end

feature 'Evernote', :js => true do
=begin
  # disabled evernote signin feature
  scenario 'signin' do
    if %i(iphone ipad safari selenium).include?(Capybara.javascript_driver)
      pending "#{Capybara.javascript_driver} doesn't support this test"
    else
      signout_evernote

      clear_session
      visit '/'
      evaluate_script("$('.secret').css('display', 'inline')")
      find('#signin-evernote').click

      wait_until(10) do
        page.has_css?('#username')
      end

      test_user = EvernoteAuth.config['tests'].first
      find('#username').set test_user['email']
      find('#password').set test_user['password']
      find('#login').click

      wait_and_find_xpath("//input[@name='reauthorize' or @name='authorize']").click

      expect(evaluate_script('session.username()')).to eq test_user['account']

      expect(current_path).to eq '/app'
      user = User.find_by_username test_user['account']
      expect(user.pages).to must_be_empty
    end
  end
=end

  scenario 'connect with existing account' do
    if %i(iphone ipad ie safari selenium).include?(Capybara.javascript_driver)
      pending "#{Capybara.javascript_driver} doesn't support this test"
    else
      signout_evernote

      user = FactoryBot.create(:testdrive1)
      test_login 'testdrive1'
      find('#nav-username-link').click

      wait_and_find_css('#settings-evernote-button').click
      sleep 1.0
      wait_and_find_css('#settings-evernote-turnon-button').click

      within_window 'wripe_auth' do
        test_user = EvernoteAuth.config['tests'].first
        wait_and_find_css('#username').set test_user['email']
        find('#password').set test_user['password'] 
        find('#login').click

        wait_and_find_xpath("//input[@name='reauthorize' or @name='authorize']").click
      end

      wait_until_visible('#settings-evernote-turnedon')

      expect(current_path).to eq '/app'
      expect(user.pages).to must_be_empty
    end
  end
end