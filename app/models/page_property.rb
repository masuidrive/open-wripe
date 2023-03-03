class PageProperty < ApplicationRecord
  belongs_to :page
  validates :key, :uniqueness => { :scope => :page_id }
end
