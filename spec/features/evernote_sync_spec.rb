require 'spec_helper'

def signout_evernote
  visit 'https://sandbox.evernote.com/Logout.action'
end

def clear_evernote_data(access_token)
  note_store = EvernoteOAuth::Client.new(token: access_token).note_store
  notebook = note_store.listNotebooks.select {|notebook| notebook.name == EvernoteUser.notebook_name }.first
  if notebook
    note_filter = Evernote::EDAM::NoteStore::NoteFilter.new(notebookGuid: notebook.guid)
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
    note_store.findNotesMetadata(note_filter, 0, 100, spec).notes.each do |note|
      note_store.deleteNote(note.guid)
    end
  end
end

def login_evernote(evernote_user, clear_data: true)
  if clear_data
    clear_evernote_data(evernote_user['access_token'])
  end
  signout_evernote
  clear_session

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
  wait_and_find("#settings-evernote .btn-close").click
  sleep 1.0 # wait for face out

  user = User.find_by_username 'testdrive1'
  expect(user.pages).to must_be_empty
  user.reload
  user
end

def get_notes(user)
  note_store = user.evernote_user.note_store
  notebook = note_store.listNotebooks.select {|notebook| notebook.name == EvernoteUser.notebook_name }.first
  expect(notebook).to must_be_nil

  note_filter = Evernote::EDAM::NoteStore::NoteFilter.new(notebookGuid: notebook.guid)
  spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new

  notes = note_store.findNotesMetadata(note_filter, 0, 100, spec).notes.map do |note|
    note_store.getNote(note.guid, true, false, false, false)
  end
end

feature 'Evernote', :js => true do
  scenario 'create new note, modify' do
    if %i(iphone ipad safari firefox selenium webkit).include?(Capybara.javascript_driver)
      pending "#{Capybara.javascript_driver} doesn't support this test"
    else
      user = login_evernote(EvernoteAuth.config['tests'].first)

      find('#navigator-new').click
      wait_until_visible $el[:edit_body]

      # create new note
      find($el[:edit_title]).set "EVERNOTE TEST NOTE1"
      find($el[:edit_body]).set "# TEST\n123\n"
      find($el[:edit_save]).click

      sleep 0.1
      wait_until_visible "#{$el[:edit_save]} span[name='save']"

      expect(user.pages.count).to eq 1

      notes = get_notes(user)
      expect(notes.count).to eq 1
      note = notes.first
      expect(note.title).to eq "EVERNOTE TEST NOTE1"
      doc = Nokogiri::HTML(note.content)
      expect(doc.css('en-note h1').text).to eq "TEST"
      expect(doc.css('en-note div p').text).to eq "123"

      find($el[:edit_title]).set "EVERNOTE TEST NOTE2"
      find($el[:edit_body]).set "# TEST2\nABC\n"
      find($el[:edit_save]).click

      wait_until_visible "#{$el[:edit_save]} span[name='save']"

      expect(user.pages.count).to eq 1

      notes = get_notes(user)
      expect(notes.count).to eq 1
      note = notes.first
      expect(note.title).to eq "EVERNOTE TEST NOTE2"
      doc = Nokogiri::HTML(note.content)
      expect(doc.css('en-note h1').text).to eq "TEST2"
      expect(doc.css('en-note div p').text).to eq "ABC"
    end
  end
end