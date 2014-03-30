class PageTag < ActiveRecord::Base
  belongs_to :user
  has_many :page_taggings, :dependent => :destroy
  has_many :pages, :through => :page_taggings
  scope :tag_name, -> tag_name { where(:name => tag_name) }

  def to_hash
    {
      name: name,
      pages_count: page_taggings_count
    }
  end
end
