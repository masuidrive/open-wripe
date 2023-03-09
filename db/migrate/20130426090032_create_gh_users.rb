class CreateGhUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :gh_users do |t|
      t.integer :user_id
      t.string :ghid, :unique => true
      t.text :token
      t.text :name
      t.text :account
      t.text :json

      t.timestamps
    end
    add_index :gh_users, :user_id
  end
end
