class CreatePageTags < ActiveRecord::Migration
  def change
    create_table :page_tags do |t|
      t.integer :user_id
      t.string :name
      t.integer :pages_count, :default => 0

      t.timestamps
    end
    add_index :page_tags, [:user_id, :name], :unique => true
    add_index :page_tags, [:user_id, :pages_count]
  end
end
