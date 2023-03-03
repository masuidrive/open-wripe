class PageUser < ApplicationRecord
  belongs_to :page
  belongs_to :user
end
