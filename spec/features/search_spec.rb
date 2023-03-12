require 'rails_helper'

def create_test_users
  user = FactoryBot.create(:testdrive1)
  FactoryBot.create(:testpage, user: user, title: 'TITLE1', body: 'BODY1')
  FactoryBot.create(:testpage, user: user, title: 'TITLE2', body: 'BODY2')

  user = FactoryBot.create(:testdrive2)
  FactoryBot.create(:testpage, user: user, title: 'TITLE1 a', body: 'BODY1 a')
  FactoryBot.create(:testpage, user: user, title: 'TITLE2 a', body: 'BODY2 a')
end

feature 'Search', :js => true, :solr => true do
  before(:each) do
    create_test_users
  end

  scenario 'search in title' do
    test_login 'testdrive1'

    wait_and_find('#navigator-search').click

    wait_and_find('#list-page-search-query').set "TITLE1"
    wait_and_find('#list-page-search-submit').click

    wait_until { has_css?('#list-page', visible: true) && find('#list-page')&.text.present? }
    expect(page).to have_content('TITLE1')
    expect(page).to have_no_content('TITLE2')
    expect(page).to have_no_content('TITLE1 a')
    expect(page).to have_no_content('TITLE2 a')

    find('#list-page-search-query').set "TITLE2"
    find('#list-page-search-submit').click

    wait_until { has_css?('#list-page', visible: true) && find('#list-page')&.text.present? }
    expect(page).to have_no_content('TITLE1')
    expect(page).to have_content('TITLE2')
    expect(page).to have_no_content('TITLE1 a')
    expect(page).to have_no_content('TITLE2 a')
  end

  scenario 'search in body' do
    test_login 'testdrive1'

    wait_and_find('#navigator-search').click

    wait_and_find('#list-page-search-query').set "BODY1"
    wait_and_find('#list-page-search-submit').click

    wait_until { has_css?('#list-page', visible:true) && find('#list-page')&.text.present? }
    expect(page).to have_no_content('TITLE1')
    expect(page).to have_no_content('TITLE2')
    expect(page).to have_no_content('TITLE1 a')
    expect(page).to have_no_content('TITLE2 a')
  end
end
