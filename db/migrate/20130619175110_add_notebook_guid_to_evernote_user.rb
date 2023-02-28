class AddNotebookGuidToEvernoteUser < ActiveRecord::Migration[4.2]
  def change
    add_column :evernote_users, :notebook_guid, :string
  end
end
