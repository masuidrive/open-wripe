class AddLockVersionToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :lock_version, :integer, :default => 0
  end
end
