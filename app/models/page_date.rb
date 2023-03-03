class PageDate < ApplicationRecord
  belongs_to :page
  belongs_to :user, optional: true
end
