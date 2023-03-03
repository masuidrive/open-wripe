class PageTagging < ApplicationRecord
  belongs_to :page
  belongs_to :page_tag, :counter_cache => true
end
