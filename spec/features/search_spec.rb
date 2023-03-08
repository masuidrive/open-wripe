require 'spec_helper'

def create_test_users
  user = FactoryBot.create(:testdrive1)
  user.pages.create :title => 'TITLE1', :body => 'BODY1'
  user.pages.create :title => 'TITLE2', :body => 'BODY2'

  user = FactoryBot.create(:testdrive2)
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

    wait_until { not find('#list-page')&.text.blank? }
    expect(page).to have_content('TITLE1')
    expect(page).to have_no_content('TITLE2')
    expect(page).to have_no_content('TITLE1 a')
    expect(page).to have_no_content('TITLE2 a')

    find('#list-page-search-query').set "TITLE2"
    find('#list-page-search-submit').click

    wait_until { not find('#list-page')&.text.blank? }
    expect(page).to have_no_content('TITLE1')
    expect(page).to have_content('TITLE2')
    expect(page).to have_no_content('TITLE1 a')
    expect(page).to have_no_content('TITLE2 a')
  end

  scenario 'search in body' do
    create_test_users
    test_login 'testdrive1'

    wait_and_find('#navigator-search').click

    wait_and_find('#list-page-search-query').set "BODY1"
    wait_and_find('#list-page-search-submit').click

    wait_until { not find('#list-page')&.text.blank? }
    expect(page).to have_no_content('TITLE1')
    expect(page).to have_no_content('TITLE2')
    expect(page).to have_no_content('TITLE1 a')
    expect(page).to have_no_content('TITLE2 a')
  end
end
