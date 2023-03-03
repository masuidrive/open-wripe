class Help < ApplicationRecord
  belongs_to :user
  scope :key, -> k { where(:key => k) }
  validates :key, :uniqueness => { :scope => :user_id }

  def to_hash(*args)
    {
      key: key,
      value: value
    }
  end
end
