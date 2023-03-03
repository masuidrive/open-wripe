class EvernoteUser < ApplicationRecord
  belongs_to :user

  def self.auth(access_token)
    enid, username = EvernoteUser.userinfo_from_access_token(access_token)

    enuser = EvernoteUser.find_by_enid(enid)
    if enuser
      enuser.user
    else
      while User.where(:username => username).count > 0
        username += rand(10).to_s
      end
      user = User.create username: username, icon_url: "#{Rails.application.routes.url_helpers.home_url.gsub(/\w+$/,'')}images/evernote_icon128.png"
      EvernoteUser.create access_token: access_token, enid: enid, evernote_username: username, user_id: user.id
      user
    end
  end

  class AlreadyConnected < Exception; end
  def self.connect(access_token, user)
    enid, username = EvernoteUser.userinfo_from_access_token(access_token)

    enuser = EvernoteUser.find_by_enid(enid)
    if enuser
      if enuser.user_id == user.id
        enuser.update_attributes access_token: access_token, evernote_username: username
      else
        raise AlreadyConnected
      end
    else
      EvernoteUser.create access_token: access_token, enid: enid, evernote_username: username, user_id: user.id
    end

    true
  end

  def save_to_evernote(page)
    if page.properties['evernote-guid']
      update_evernote(page)
    else
      create_evernote(page)
    end
  end

  def update_evernote(page)
    note = note_store.getNote(page.properties['evernote-guid'], true, false, false, false)
    note.title = page.title.strip
    note.content = <<__XML__
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note><p><a href="#{page.edit_url}">Edit this page in wri.pe</a></p><hr/><div>#{page.body_html}</div></en-note>
__XML__
    note.attributes.contentClass = 'masuidrive.wripe'
    note_store.updateNote(note)
    note
  rescue Evernote::EDAM::Error::EDAMNotFoundException
    create_evernote(page)
  end

  def create_evernote(page)
    note = Evernote::EDAM::Type::Note.new
    note.title = page.title.strip
    note.content = <<__XML__
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note><p><a href="#{page.edit_url}">Edit this page in wri.pe</a></p><hr/><div>#{page.body_html}</div></en-note>
__XML__
    note.tagNames = ['wri.pe']
    note.notebookGuid = notebook_guid || default_notebook_guid
    attribs = Evernote::EDAM::Type::NoteAttributes.new
    attribs.contentClass = 'masuidrive.wripe'
    note.attributes = attribs
    begin
      note = note_store.createNote(note)
    rescue Evernote::EDAM::Error::EDAMNotFoundException
      note.notebookGuid = default_notebook_guid
      note = note_store.createNote(note)
    end
    page.properties['evernote-guid'] = note.guid
    note
  end

  def default_notebook_guid
    notebook = note_store.listNotebooks.select {|notebook| notebook.name == EvernoteUser.notebook_name }.first
 
    if notebook.present?
      guid = notebook.guid
    else
      notebook = Evernote::EDAM::Type::Notebook.new
      notebook.name = EvernoteUser.notebook_name
      guid = note_store.createNotebook(notebook).guid
    end
    update_attributes notebook_guid: guid
    guid
  end

  def self.userinfo_from_access_token(access_token)
    client = EvernoteAuth.oauth(access_token)
    enuser = client.user_store.getUser
    [enuser.id, enuser.username]
  end

  def client
    @client ||= EvernoteAuth.oauth(access_token)
  end

  def note_store
    @note_store ||= client.note_store
  end

  def self.notebook_name
    @notebook_name ||= {
      development: 'wripe-dev notebook',
      test: 'wripe-test notebook',
    }[Rails.env.to_sym] || 'wri.pe notebook'
  end
end
