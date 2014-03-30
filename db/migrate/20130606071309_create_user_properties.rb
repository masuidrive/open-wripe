class CreateUserProperties < ActiveRecord::Migration
  def change
    create_table :user_properties do |t|
      t.integer :user_id
      t.string :key
      t.text :value

      t.timestamps
    end
    add_index :user_properties, [:user_id, :key], :unique => true
    
    User.all.each do |user|
      user.create_default_properties
    end
  end
end
