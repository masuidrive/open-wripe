require 'spec_helper'

def create_test_users
  user = FactoryGirl.create(:testdrive1)
  user.pages.create :title => 'TITLE1', :body => 'BODY1'
  user.pages.create :title => 'TITLE2', :body => 'BODY2'

  user = FactoryGirl.create(:testdrive2)
  user.pages.create :title => 'TITLE1 a', :body => 'BODY1 a'
  user.pages.create :title => 'TITLE2 a', :body => 'BODY2 a'
end

feature 'Search', :js => true, :solr => true do
  scenario 'search in title' do
    create_test_users
    test_login 'testdrive1'

    wait_and_find('#navigator-search').click
    
    wait_and_find('#list-page-search-query').set "TITLE1"
    wait_and_find('#list-page-search-submit').click

    wait_until { not find('#list-page').text.blank? }
    page.should have_content('TITLE1')
    page.should_not have_content('TITLE2')
    page.should_not have_content('TITLE1 a')
    page.should_not have_content('TITLE2 a')

    find('#list-page-search-query').set "TITLE2"
    find('#list-page-search-submit').click

    wait_until { not find('#list-page').text.blank? }
    page.should_not have_content('TITLE1')
    page.should have_content('TITLE2')
    page.should_not have_content('TITLE1 a')
    page.should_not have_content('TITLE2 a')
  end

  scenario 'search in body' do
    create_test_users
    test_login 'testdrive1'

    wait_and_find('#navigator-search').click
    
    wait_and_find('#list-page-search-query').set "BODY1"
    wait_and_find('#list-page-search-submit').click

    wait_until { not find('#list-page').text.blank? }
    page.should have_content('TITLE1')
    page.should_not have_content('TITLE2')
    page.should_not have_content('TITLE1 a')
    page.should_not have_content('TITLE2 a')
  end
end
