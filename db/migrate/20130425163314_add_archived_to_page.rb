class AddArchivedToPage < ActiveRecord::Migration
  def change
    add_column :pages, :archived, :boolean, :default => false
    add_index :pages, [:user_id, :archived, :updated_at]
  end
end
