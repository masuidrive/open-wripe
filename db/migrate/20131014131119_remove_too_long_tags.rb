class RemoveTooLongTags < ActiveRecord::Migration[4.2]
  def up
    PageTag.where('LENGTH(page_tags.name) > 32').destroy_all
  end
  def down
  end
end
