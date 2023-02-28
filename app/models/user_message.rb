class UserMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender_user, :class_name => 'User', optional: true
  belongs_to :page, optional: true
  scope :user, -> u { where(user: u) }
  scope :page, -> p { where(page: p) }
  scope :type, -> t { where(message_type: t) }
  scope :read, -> p { where(read: true) }
  scope :unread, -> p { where(read: false) }
  validate :message_type, :inclusion => { :in => %w(free sidehelp) }

  def to_hash(*args)
    {
      user: user ? user.to_hash : nil,
      sender: sender_user ? sender_user.to_hash : nil,
      page: page ? page.to_hash : nil,
      title: title,
      body: body,
      read: read?,
      icon_url: icon_url
    }
  end
end
