require 'spec_helper'

feature 'create new note', :js => true do
  scenario 'create note' do
    user = FactoryBot.create(:testdrive1)
    test_login 'testdrive1'

    find('#navigator-new').click
    wait_until_visible $el[:edit_body]

    # create new note
    find($el[:edit_title]).set "TEST NOTE"
    find($el[:edit_body]).set "TEST\n123\n"
    find($el[:edit_save]).click

    sleep 0.5
    wait_until_visible "#{$el[:edit_save]} span[name='save']"

    expect(user.pages.count).to eq 1
    expect(user.pages.first.lock_version).to eq 0
    expect(user.pages.first.title).to eq "TEST NOTE"
    expect(user.pages.first.body).to eq "TEST\n123\n"
    
    # modify
    find($el[:edit_title]).set "TEST NOTE2"
    find($el[:edit_body]).set "TEST\nABC\n"
    find($el[:edit_save]).click
    
    sleep 0.5
    wait_until_visible "#{$el[:edit_save]} span[name='save']"
     
    expect(user.pages.count).to eq 1
    expect(user.pages.first.lock_version).to eq 1
    expect(user.pages.first.title).to eq "TEST NOTE2"
    expect(user.pages.first.body).to eq "TEST\nABC\n"
  end
end
