class User < ApplicationRecord
  after_create :create_defaults
  after_create :generate_export_key
  has_one :fb_user, :dependent => :destroy
  has_one :gh_user, :dependent => :destroy
  has_one :dropbox_user, :dependent => :destroy
  has_one :evernote_user, :dependent => :destroy
  has_many :pages, :dependent => :destroy
  has_many :page_tags, :dependent => :destroy
  has_many :messages, :class_name => 'UserMessage', :dependent => :destroy
  has_many :properties, :class_name => 'UserProperty', :dependent => :destroy, :extend => PropExtend
  has_many :helps, :dependent => :destroy do
    def clear(key)
      key(key.to_s).destroy_all
    end
  end

  def to_hash(*args)
    {
      user_id: self.id,
      username: username,
      icon_url: icon_url
    }
  end

  def create_default_helps
    helps.create key: 'whatsnew'
    helps.create key: 'backup'
    helps.create key: 'mobile'
    helps.create key: 'hotkey'
    helps.create key: 'calendar'
    helps.create key: 'upcoming'
    helps.create key: 'calendar-external'
    helps.create key: 'evernote'
  end

  def create_defaults
    create_default_helps
    properties['autosave'] = true
    properties['version'] = WRIPE_VERSION
  end

  def merge(u)
    status = self.properties['marge_status'].to_s
    return false unless ['', 'queued'].include?(status) || status[0, 6] == 'error:'

    if u.evernote_user && self.evernote_user
      raise "Cannot merge accounts, both accounts connected with Evernote"
    end
    
    self.properties['marge_status'] = 'marging'
    ActiveRecord::Base.transaction do
      u.pages(true).each do |page|
        page.user = self
        page.save!
      end

      if u.pages(true).count == 0
        u.update_attributes active: false
      else
        raise "Unknown error"
      end

      if self.evernote_user.nil? && u.evernote_user
        u.evernote_user.update_attributes user_id: self.id
      end
      
      # send all pages to evernote
      if self.evernote_user || u.evernote_user
        self.pages(true).each do |page|
          page.save_to_evernote
        end
      end
    end

    self.properties['marge_status'] = nil
  rescue => e
    self.properties['marge_status'] = "error:#{e.message}"
  end

  def generate_export_key
    @@key_string ||= [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    string1 = (0...48).map{ @@key_string[rand(@@key_string.length)] }.join
    string2 = (0...48).map{ @@key_string[rand(@@key_string.length)] }.join
    key = "#{string1}#{self.id % 256}#{string2}#{self.id / 256}"
    properties['export-key'] = key
  end

  def is_admin?
    self.id == 1
  end
end
