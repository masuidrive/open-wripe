class AddArchivedToPage < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :archived, :boolean, :default => false
    add_index :pages, [:user_id, :archived, :updated_at]
  end
end
