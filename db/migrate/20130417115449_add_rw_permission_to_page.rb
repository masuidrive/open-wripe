class AddRwPermissionToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :read_permission, :integer, :default => 0
    add_column :pages, :write_permission, :integer, :default => 0
  end
end
