class AddLockVersionToPage < ActiveRecord::Migration
  def change
    add_column :pages, :lock_version, :integer, :default => 0
  end
end
