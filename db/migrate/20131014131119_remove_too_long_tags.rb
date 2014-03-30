class RemoveTooLongTags < ActiveRecord::Migration
  def up
    PageTag.where('LENGTH(page_tags.name) > 32').destroy_all
  end
  def down
  end
end
