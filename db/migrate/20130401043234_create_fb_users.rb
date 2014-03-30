class CreateFbUsers < ActiveRecord::Migration
  def change
    create_table :fb_users do |t|
      t.integer :user_id
      t.text :token
      t.text :name
      t.text :account

      t.timestamps
    end
    add_index :fb_users, :user_id
  end
end
