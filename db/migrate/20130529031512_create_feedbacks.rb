class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :user_id
      t.boolean :closed
      t.boolean :opened
      t.integer :subject
      t.text :body
      t.text :admin_note

      t.timestamps
    end
    add_attachment :feedbacks, :image
    add_index :feedbacks, [:user_id, :created_at]
    add_index :feedbacks, [:opened, :created_at]
    add_index :feedbacks, [:closed, :created_at]
    add_index :feedbacks, [:subject, :created_at]
    add_index :feedbacks, [:closed, :subject, :created_at]
  end
end
