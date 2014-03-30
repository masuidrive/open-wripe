class CreateDropboxUsers < ActiveRecord::Migration
  def change
    create_table :dropbox_users do |t|
      t.integer :user_id, :unique => true
      t.string :auth_token
      t.string :auth_secret

      t.timestamps
    end
  end
end
