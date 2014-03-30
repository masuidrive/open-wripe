class UpdateTaggings < ActiveRecord::Migration
  def up
    Page.find_each do |page|
      page.send 'generate_tags'
    end
  end
  def down
  end
end
