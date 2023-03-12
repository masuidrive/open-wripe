require 'spec_helper'
feature 'Modify note', :js => true do

  before(:each) do
    @user = FactoryBot.create(:testdrive1)
    @page = FactoryBot.create(:testpage, user: @user, title: 'TITLE', body: 'BODY')
  end

  scenario 'load exists note, modify and save' do
    test_login 'testdrive1'

    wait_until do
      has_css?('#list-page', visible: true) && find('#list-page')&.text.present?
    end

    expect(find("#list-page-#{@page.key} .title")).to have_content("TITLE")
    find("#list-page-#{@page.key} .title a").click
    wait_until_visible $el[:edit_body]

    find($el[:edit_title]).set "TEST NOTE"
    find($el[:edit_body]).set "TEST\n123\n"
    find($el[:edit_save]).click

    wait_until_visible "#{$el[:edit_save]} span[name='save']"

    expect(@user.pages.count).to eq 1
    expect(@user.pages.first.lock_version).to eq 1
    expect(@user.pages.first.title).to eq "TEST NOTE"
    expect(@user.pages.first.body).to eq "TEST\n123\n"

    find('#navigator-index').click
    wait_until_visible '#list-page'

    expect(wait_and_find("#list-page-#{@page.key} .title")).to have_content("TEST NOTE")
  end

  feature ' and conflict', :js => true do
    scenario 'modify and conflict' do
      test_login 'testdrive1'

      wait_until do
        has_css?('#list-page', visible: true) && find('#list-page')&.text.present?
      end

      expect(find("#list-page-#{@page.key} .title")).to have_content("TITLE")
      find("#list-page-#{@page.key} .title a").click

      wait_until_visible $el[:edit_body]
      expect(find($el[:edit_body]).value).to eq 'BODY'

      @page.update_attributes body: "BODY\n1\n2\n"

      find($el[:edit_body]).set "BODY\n123\n"
      find($el[:edit_save]).click

      wait_until_visible "#{$el[:edit_save]} span[name='save']"

      wait_until_visible '#page-edit-conflict .btn-close'
      sleep 1.0 # wait fade out
      find('#page-edit-conflict .btn-close').click
      sleep 1.0 # wait fade out

      expect(find($el[:edit_body]).value).to eq "BODY\n123\n\n1\n2\n\n"
      find($el[:edit_save]).click

      wait_until_visible "#{$el[:edit_save]} span[name='save']"

      expect(@user.pages.count).to eq 1
      expect(@user.pages.first.lock_version).to eq 2
      expect(@user.pages.first.body).to eq "BODY\n123\n\n1\n2\n\n"
    end
  end

  feature ' and delay', :js => true do
    scenario 'modify and conflict' do
      test_login 'testdrive1'

      wait_until do
        has_css?('#list-page', visible: true) && find('#list-page')&.text.present?
      end

      expect(find("#list-page-#{@page.key} .title")).to have_content("TITLE")
      find("#list-page-#{@page.key} .title a").click

      wait_until_visible $el[:edit_body]
      expect(find($el[:edit_body]).value).to eq 'BODY'

      find($el[:edit_body]).set "BODY\n123\n"

      PagesController._delay = 2.0
      find($el[:edit_save]).click
      sleep 0.5

      expect(find($el[:edit_body]).value).to eq "BODY\n123\n"
      find($el[:edit_body]).set "BODY\n1\n2"

      wait_until_visible "#{$el[:edit_save]} span[name='save']"
      expect(find($el[:edit_body]).value).to eq "BODY\n1\n2"

      expect(@user.pages.count).to eq 1
      expect(@user.pages.first.lock_version).to eq 1
      expect(@user.pages.first.body).to eq "BODY\n123\n"

      PagesController._delay = nil
      find($el[:edit_save]).click

      wait_until_visible "#{$el[:edit_save]} span[name='save']"
      expect(find($el[:edit_body]).value).to eq "BODY\n1\n2"

      expect(@user.pages.count).to eq 1
      expect(@user.pages.first.lock_version).to eq 2
      expect(@user.pages.first.body).to eq "BODY\n1\n2"
    end
  end
end
