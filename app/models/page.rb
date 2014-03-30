class Page < ActiveRecord::Base
  attr_accessor :dates_json
  before_create :generate_key
  around_save :save_to_history
  after_save :save_to_evernote
  after_save :create_sunspot_index
  after_save :generate_dates, :generate_tags
  belongs_to :user
  has_many :page_users, :dependent => :destroy
  has_many :users, :through => :page_users
  has_many :histories, :class_name => 'PageHistory', :dependent => :destroy
  has_many :dates, :class_name => 'PageDate', :dependent => :destroy
  has_many :page_taggings, :dependent => :destroy
  has_many :page_tags, :through => :page_taggings
  has_many :properties, :class_name => 'PageProperty', :dependent => :destroy, :extend => PropExtend

  scope :inbox, -> { where(:archived => false) }
  scope :archived, -> { where(:archived => true) }
  scope :date, -> date { includes(:dates).where('page_dates.date=?', date).references(:dates) }
  scope :date_range, -> sdate, edate { includes(:dates).where('page_dates.date >= ? AND page_dates.date <= ?', sdate, edate).references(:dates) }

  searchable auto_index: false do
    text    :title
    text    :body
    integer :user_id
    boolean :archived, :using => :archived?
    integer :modified_at
  end

  @@markdown = Redcarpet::Markdown.new Redcarpet::Render::HTML,
    autolink: true,
    space_after_headers: true,
    no_intra_emphasis: true,
    fenced_code_blocks: true,
    tables: true,
    hard_wrap: true,
    xhtml: true,
    lax_html_blocks: true,
    strikethrough: true

  ONLY_ME = 0
  SHARE_URL = 10

  def body=(val)
    write_attribute :body, val.to_s.gsub(/\r/, '')
  end

  # read_permission
  def permit_read?(user_, password=nil)
    return true if user_ == user
    case read_permission
    when SHARE_URL
      true
    else
      return false unless user_
      self.page_users.where(:user_id => user_.id, :read_permission => true).count > 0
    end
  end

  def permit_write?(user_)
    return true if user_ == user
    return false unless user_
    self.page_users.where(:user_id => user_.id, :write_permission => true).count > 0
  end

  def permit_share?(user_)
    return true if user_ == user
    return false unless user_
    self.page_users.where(:user_id => user_.id, :share_permission => true).count > 0
  end

  def to_param
    key
  end

  def url
    options = {}
    options[:protocol] = 'https' if Rails.env == 'production'
    Rails.application.routes.url_helpers.page_url(self, options)
  end

  def edit_url
    options = {}
    options[:protocol] = 'https' if Rails.env == 'production'
    Rails.application.routes.url_helpers.edit_page_url(self, options)
  end

  def body_html
    html = @@markdown.render(self.body)
    html = Sanitize.clean(html, Sanitize::Config::RELAXED).gsub(/<br>/i, '<br />')
    doc = Nokogiri::XML.fragment(html)
    doc.css("a").each do |node|
      uri = URI.parse(node['href'])
      if %w(http https).include?(uri.scheme)
        node['href'] = uri.to_s
      else
        node.name = 'span'
        node.attributes['href'].remove
      end
    end
    doc.to_s
  end

  def to_hash(options={})
    data = {
      :key => key,
      :lock_version => lock_version,
      :archived => archived?,
      :title => (title || '').strip.blank? ? 'No title' : title,
      :user => user.to_hash,
      :read_permission => read_permission,
      :modified_at => modified_at,
      :created_at => created_at.to_i,
      :url => url
    }
    data[:body] = (body || '') unless options[:body] === false
    if options[:user]
      data[:editable] = permit_write?(options[:user])
    end
    data[:dates] = self.dates.map{|d| d.date.strftime("%Y/%m/%d")} if options[:dates]
    data
  end

  def save_to_evernote
    if user.evernote_user
      user.evernote_user.async :save_to_evernote, self
    end
    true
  end

  private
  def create_sunspot_index
    self.async :index!
    true
  end

  private
  def save_to_history
    self.modified_at = Time.now.to_i if (self.modified_at || 0).to_i == 0
    changed = self.title_changed? || self.body_changed?
    yield
    histories.create(:body => body, :title => title, :page_lock_version => lock_version) if changed
  end

  private
  def generate_key
    self.key ||= ([0]+6.times.map{rand(10+26*2)}).map { |i|
      '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'[i, 1]
    }.join
  end

  private
  def generate_dates
    return if dates_json.blank?

    ActiveRecord::Base.transaction do
      self.dates.destroy_all
      JSON.parse(dates_json).uniq.each do |d|
        self.dates.create date: Time.at(d.to_i), user_id: self.user_id
      end
    end
    dates_json = nil
  rescue
    # no-op
  end

  private
  def generate_tags
    ActiveRecord::Base.transaction do
      self.page_taggings.destroy_all
      (
        [self.title, self.body, ''].join("\n")
        .gsub(/^```.*?\n.*?```\n/m, '')
        .gsub(/`.*?`/, '')
        .scan(%r{\[([^\r\n\[\]]{1,32})\](?![\(:])}).flatten.uniq -
        (self.body || '').scan(%r|^\s*\[([^\[\]]+)\]:|).flatten
      ).each do |name|
        self.page_taggings.create page_tag: self.user.page_tags.find_or_create_by(name: name.to_s)
      end
    end
  end
end
