class CreateChatroomUser < ActiveRecord::Migration
  def change
    create_table :chatroom_users do |t|
      t.integer :chatroom_id
      t.integer :user_id

      t.timestamps
    end
    add_index :chatroom_users, [:chatroom_id, :user_id], :unique => true
  end
end
