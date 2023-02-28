class CreateEvernoteUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :evernote_users do |t|
      t.integer :user_id
      t.integer :enid
      t.string :evernote_username
      t.string :access_token
      t.timestamp :expiration

      t.timestamps
    end
    add_index :evernote_users, [:enid], unique: true
    add_index :evernote_users, [:expiration], unique: true
    add_index :evernote_users, [:user_id], unique: true
  end
end
