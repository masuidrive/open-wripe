class AddActiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, default: true
    add_index :users, :active
  end
end
