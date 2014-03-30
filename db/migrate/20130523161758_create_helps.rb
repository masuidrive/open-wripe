class CreateHelps < ActiveRecord::Migration
  def change
    create_table :helps do |t|
      t.integer :user_id
      t.string :key
      t.string :value

      t.timestamps
    end
    add_index :helps, [:user_id]
    add_index :helps, [:user_id, :key], :unique => true
    User.all.each(&:create_default_helps) rescue nil
  end
end
