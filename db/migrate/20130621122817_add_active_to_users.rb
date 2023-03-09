class AddActiveToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :active, :boolean, default: true
    add_index :users, :active
  end
end
