class CreatePageHistories < ActiveRecord::Migration[4.2]
  def change
    create_table :page_histories do |t|
      t.integer :page_id
      t.text :body
      t.text :title
      t.integer :page_lock_version

      t.timestamps
    end
    add_index :page_histories, [:page_id, :created_at]
  end
end
