require 'spec_helper'
feature 'Modify note', :js => true do
  scenario 'load exists note, modify and save' do
    user = FactoryGirl.create(:testdrive1)
    page = user.pages.create :title => 'TITLE', :body => 'BODY'

    test_login 'testdrive1'

    wait_until do
      not find('#list-page').text.blank?
    end

    find("#list-page-#{page.key} .title").should have_content("TITLE")
    find("#list-page-#{page.key} .title a").click
    wait_until_visible $el[:edit_body]

    find($el[:edit_title]).set "TEST NOTE"
    find($el[:edit_body]).set "TEST\n123\n"
    find($el[:edit_save]).click

    wait_until_visible "#{$el[:edit_save]} span[name='save']"

    user.pages.count.should == 1
    user.pages.first.lock_version.should == 1
    user.pages.first.title.should == "TEST NOTE"
    user.pages.first.body.should == "TEST\n123\n"

    find('#navigator-index').click
    wait_until_visible '#list-page'

    wait_and_find("#list-page-#{page.key} .title").should have_content("TEST NOTE")
  end
end

feature 'Modify note and conflict', :js => true do
  scenario 'modify and conflict' do
    user = FactoryGirl.create(:testdrive1)
    page = user.pages.create :title => 'TITLE', :body => 'BODY'

    test_login 'testdrive1'

    wait_until do
      not find('#list-page').text.blank?
    end

    find("#list-page-#{page.key} .title").should have_content("TITLE")
    find("#list-page-#{page.key} .title a").click

    wait_until_visible $el[:edit_body]
    find($el[:edit_body]).value.should == 'BODY'

    page.update_attributes body: "BODY\n1\n2\n"

    find($el[:edit_body]).set "BODY\n123\n"
    find($el[:edit_save]).click

    wait_until_visible "#{$el[:edit_save]} span[name='save']"

    wait_until_visible '#page-edit-conflict .btn-close'
    sleep 1.0 # wait fade out
    find('#page-edit-conflict .btn-close').click
    sleep 1.0 # wait fade out

    find($el[:edit_body]).value.should == "BODY\n123\n\n1\n2\n\n"
    find($el[:edit_save]).click

    wait_until_visible "#{$el[:edit_save]} span[name='save']"

    user.pages.count.should == 1
    user.pages.first.lock_version.should == 2
    user.pages.first.body.should == "BODY\n123\n\n1\n2\n\n"
  end
end

feature 'Modify note and delay', :js => true do
  scenario 'modify and conflict' do
    user = FactoryGirl.create(:testdrive1)
    page = user.pages.create :title => 'TITLE', :body => 'BODY'

    test_login 'testdrive1'

    wait_until do
      not find('#list-page').text.blank?
    end

    find("#list-page-#{page.key} .title").should have_content("TITLE")
    find("#list-page-#{page.key} .title a").click

    wait_until_visible $el[:edit_body]
    find($el[:edit_body]).value.should == 'BODY'

    find($el[:edit_body]).set "BODY\n123\n"

    PagesController._delay = 2.0
    find($el[:edit_save]).click
    sleep 0.5

    find($el[:edit_body]).value.should == "BODY\n123\n"
    find($el[:edit_body]).set "BODY\n1\n2"

    wait_until_visible "#{$el[:edit_save]} span[name='save']"
    find($el[:edit_body]).value.should == "BODY\n1\n2"

    user.pages.count.should == 1
    user.pages.first.lock_version.should == 1
    user.pages.first.body.should == "BODY\n123\n"

    PagesController._delay = nil
    find($el[:edit_save]).click

    wait_until_visible "#{$el[:edit_save]} span[name='save']"
    find($el[:edit_body]).value.should == "BODY\n1\n2"

    user.pages.count.should == 1
    user.pages.first.lock_version.should == 2
    user.pages.first.body.should == "BODY\n1\n2"
  end
end
