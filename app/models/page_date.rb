class PageDate < ActiveRecord::Base
  belongs_to :page
  belongs_to :user, optional: true
end
