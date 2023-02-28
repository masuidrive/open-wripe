class AddActivedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :actived_at, :timestamp
    add_index :users, [:actived_at]
  end
end
