class AddPageTaggingsCountToPageTags < ActiveRecord::Migration[4.2]
  def change
    add_column :page_tags, :page_taggings_count, :integer, :default => 0
    remove_column :page_tags, :pages_count
    add_index :page_tags, [:user_id, :page_taggings_count]
  end
end
