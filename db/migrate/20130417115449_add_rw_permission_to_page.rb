class AddRwPermissionToPage < ActiveRecord::Migration
  def change
    add_column :pages, :read_permission, :integer, :default => 0
    add_column :pages, :write_permission, :integer, :default => 0
  end
end
