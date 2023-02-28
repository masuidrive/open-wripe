class CreateChatMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :chat_messages do |t|
      t.integer :user_id
      t.integer :chatroom_id
      t.text :body

      t.timestamps
    end
    add_index :chat_messages, :chatroom_id
  end
end
