class AddModifiedAtToPage < ActiveRecord::Migration
  def change
    add_column :pages, :modified_at, :integer
    add_index :pages, [:user_id, :modified_at]
    add_index :pages, [:user_id, :archived, :modified_at]
    Page.all.each do |page|
      page.update_attribute :modified_at, page.updated_at.to_i
    end
    Page.reindex
  end
end
