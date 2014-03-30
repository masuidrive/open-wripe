class CreateUserMessages < ActiveRecord::Migration
  def change
    create_table :user_messages do |t|
      t.integer :user_id
      t.integer :page_id
      t.boolean :read, :default => false
      t.string :type, :default => 'free'
      t.text :title
      t.text :body
      t.text :icon_url

      t.timestamps
    end
    add_index :user_messages, [:user_id, :created_at]
    add_index :user_messages, [:user_id, :read, :created_at]
    add_index :user_messages, [:user_id, :page_id, :read, :created_at], :name => 'idx_user_messages_3'
  end
end
