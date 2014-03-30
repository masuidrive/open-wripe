class AddNotebookGuidToEvernoteUser < ActiveRecord::Migration
  def change
    add_column :evernote_users, :notebook_guid, :string
  end
end
