class CreatePageUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :page_users do |t|
      t.integer :page_id
      t.integer :user_id
      t.boolean :read_permission, :default => true
      t.boolean :write_permission, :default => true
      t.boolean :share_permission, :default => true

      t.timestamps
    end
    add_index :page_users, [:page_id, :user_id], :unique => true
    add_index :page_users, [:user_id]
  end
end
