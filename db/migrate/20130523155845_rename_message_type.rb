class RenameMessageType < ActiveRecord::Migration[4.2]
  def change
    rename_column :user_messages, :type, :message_type
    add_index :user_messages, [:user_id, :message_type, :created_at], :name => 'idx_user_messages_4'
    add_index :user_messages, [:user_id, :message_type, :read, :created_at], :name => 'idx_user_messages_5'
  end
end
