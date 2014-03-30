class CreatePageProperties < ActiveRecord::Migration
  def change
    create_table :page_properties do |t|
      t.integer :page_id
      t.string :key
      t.text :value

      t.timestamps
    end
    add_index :page_properties, [:page_id, :key], :unique => true
  end
end
