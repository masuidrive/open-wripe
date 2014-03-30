class AddBackupsToDropboxUsers < ActiveRecord::Migration
  def change
    add_column :dropbox_users, :backups, :text
  end
end
