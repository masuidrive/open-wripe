class UserProperty < ApplicationRecord
  belongs_to :user
  validates :key, :uniqueness => { :scope => :user_id }
end
