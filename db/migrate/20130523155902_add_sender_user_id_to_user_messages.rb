class AddSenderUserIdToUserMessages < ActiveRecord::Migration
  def change
    add_column :user_messages, :sender_user_id, :integer
    add_index :user_messages, [:user_id, :sender_user_id, :created_at], :name => 'idx_user_messages_6'
  end
end
