class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :user_id
      t.text :title
      t.text :body
      t.string :key, :unique => true
      t.integer :share_status

      t.timestamps
    end
    add_index :pages, [:user_id, :updated_at]
  end
end
