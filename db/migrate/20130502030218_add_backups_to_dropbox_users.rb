class AddBackupsToDropboxUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :dropbox_users, :backups, :text
  end
end
