class PageTagging < ActiveRecord::Base
  belongs_to :page
  belongs_to :page_tag, :counter_cache => true
end
