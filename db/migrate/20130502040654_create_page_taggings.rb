class CreatePageTaggings < ActiveRecord::Migration[4.2]
  def change
    create_table :page_taggings do |t|
      t.integer :page_id
      t.integer :page_tag_id

      t.timestamps
    end
    add_index :page_taggings, [:page_id, :page_tag_id], :unique => true
  end
end
