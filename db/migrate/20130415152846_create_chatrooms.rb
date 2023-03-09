class CreateChatrooms < ActiveRecord::Migration[4.2]
  def change
    create_table :chatrooms do |t|
      t.string :key, :unique => true
      t.string :name
      t.string :user_id

      t.timestamps
    end
    add_index :chatrooms, :user_id
  end
end
