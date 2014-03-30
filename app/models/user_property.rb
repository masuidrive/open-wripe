class UserProperty < ActiveRecord::Base
  belongs_to :user
  validates :key, :uniqueness => { :scope => :user_id }
end
