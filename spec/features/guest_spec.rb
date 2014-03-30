require 'spec_helper'

feature 'Guest', :js => true do
   scenario 'access to app page' do
    visit '/app'
    sleep 2.0 # waiting redirection in Javascript
    current_path.should.should == '/'
  end
end
