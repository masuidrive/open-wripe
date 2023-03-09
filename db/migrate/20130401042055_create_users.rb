class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :username

      t.timestamps
    end
    add_index :users, :username, :unique => true
  end
end
