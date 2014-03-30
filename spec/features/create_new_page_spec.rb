require 'spec_helper'

feature 'create new note', :js => true do
  scenario 'create note' do
    user = FactoryGirl.create(:testdrive1)
    test_login 'testdrive1'

    find('#navigator-new').click
    wait_until_visible $el[:edit_body]

    # create new note
    find($el[:edit_title]).set "TEST NOTE"
    find($el[:edit_body]).set "TEST\n123\n"
    find($el[:edit_save]).click

    sleep 0.5
    wait_until_visible "#{$el[:edit_save]} span[name='save']"

    user.pages.count.should == 1
    user.pages.first.lock_version.should == 0
    user.pages.first.title.should == "TEST NOTE"
    user.pages.first.body.should == "TEST\n123\n"
    
    # modify
    find($el[:edit_title]).set "TEST NOTE2"
    find($el[:edit_body]).set "TEST\nABC\n"
    find($el[:edit_save]).click
    
    sleep 0.5
    wait_until_visible "#{$el[:edit_save]} span[name='save']"
     
    user.pages.count.should == 1
    user.pages.first.lock_version.should == 1
    user.pages.first.title.should == "TEST NOTE2"
    user.pages.first.body.should == "TEST\nABC\n"
  end
end
