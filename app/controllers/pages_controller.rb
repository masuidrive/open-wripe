class PagesController < ApplicationController
  before_filter :required_login, except: [:show]
  before_filter :prepage_variants, only: [:show, :edit, :update, :destroy, :archive, :unarchive]
  if %w(test development).include?(Rails.env)
    before_filter :delay_for_test
    cattr_accessor :_delay
  end
  PER_PAGE = 10

  def index
    tag = params[:tag]
    if tag
      page_tag = current_user.page_tags.tag_name(tag).first
      if page_tag
        load_pages page_tag.pages
      else
        @pages = []
        @total_pages = 0
      end

      render_pages \
        old_pages_url: -> { "/pages/tagged.json?name=#{name}&old=#{@pages.last.modified_at}" },
        new_pages_url: -> { "/pages/tagged.json?name=#{name}&new=#{@pages.first.modified_at}" },
        options: {
          name: tag,
        }
    else
      load_pages current_user.pages.inbox
      render_pages \
        old_pages_url: -> { "/pages.json?old=#{@pages.last.modified_at}" },
        new_pages_url: -> { "/pages.json?new=#{@pages.first.modified_at}" }
    end
  end

  def archived
    load_pages current_user.pages.archived
    render_pages \
      old_pages_url: -> { "/pages/archived.json?old=#{@pages.last.modified_at}" },
      new_pages_url: -> { "/pages/archived.json?new=#{@pages.first.modified_at}" }
  end

  def calendar
    date = Date.new(params[:year].to_i, params[:month].to_i, 1)
    load_pages current_user.pages.inbox.date_range(date, date.end_of_month)
    render_pages \
      pages: @pages.includes(:dates).map { |p| p.to_hash(user: current_user, body: false, dates: true) },
      old_pages_url: -> { "/pages/calendar.json?year=#{date.year}&month=#{date.month}&old=#{@pages.last.modified_at}" },
      new_pages_url: -> { "/pages/calendar.json?year=#{date.year}&month=#{date.month}&new=#{@pages.first.modified_at}" },
      options: {
        year: date.year,
        month: date.month
      }
  end

  def tags
    tags = current_user.page_tags.where('page_tags.page_taggings_count > 0').sort_by(&:updated_at).reverse.map(&:to_hash)
    render :json => tags
  end

  def search
    pageno = (params[:page] || 0).to_i
    query = (params[:q] || '').strip
    if query.blank?
      @pages = []
      @total_pages = @current_index = 0
    else
      search = Sunspot.search(Page) do
        fulltext query
        with :user_id, current_user.id
        order_by :modified_at, :desc
        paginate :page => pageno + 1, :per_page => PER_PAGE
      end
      @pages = search.results.select { |p| p.user_id == current_user.id }
      @total_pages = search.total
      @current_index = pageno * PER_PAGE
    end

    render_pages \
      old_pages_url: -> { "/pages/search.json?page=#{pageno + 1}&q=#{CGI.escape query}" },
      new_pages_url: -> { "/pages/search.json?page=#{pageno - 1}&q=#{CGI.escape query}" }
  end

  def new
    @page = current_user.pages.create :title => "#{Date.today.strftime('%Y/%m/%d')} New page"
    redirect_to edit_pages_url(@page)
  end

  def create
    @page = current_user.pages.create params.require(:page).permit(:title, :body, :read_permission, :dates_json).merge(modified_at: Time.now.to_i)

    respond_to do |format|
      format.json { render :json => { page: @page.to_hash } }
    end
  end

  def show
    return forbidden unless @page.permit_read?(current_user)
    respond_to do |format|
      format.html do 
        @page_title = @page.title
        render
      end
      format.json { render :json => { page: @page.to_hash } }
    end
  end

  def edit
    redirect_to "/app##{@page.key}/edit"
  end

  def update
    return forbidden unless @page.permit_write?(current_user)
    # BlockProfiler.measure do
      if params[:merge]
        # todo
      else
        if @page.lock_version != params[:page].delete(:lock_version).to_i
          return result_conflict
        end
        @page.update_attributes params.require(:page).permit(:title, :body, :read_permission, :archived, :dates_json).merge(modified_at: Time.now.to_i)
      end

      respond_to do |format|
        format.html { redirect_to edit_pages_url(@page) }
        format.json { render :json => { page: @page.to_hash } }
      end
    # end
  rescue ActiveRecord::StaleObjectError => e
    result_conflict
  end

  def destroy
    return forbidden unless @page.permit_write?(current_user)
    @page.destroy!
    respond_to do |format|
      format.html { redirect_to :top }
      format.json { render :json => { page: @page.to_hash } }
    end
  end

  def archive
    return forbidden unless @page.permit_write?(current_user)
    @page.update_attribute :archived, true    
    render :json => @page.to_hash

  rescue ActiveRecord::StaleObjectError => e
    result_conflict
  end

  def unarchive
    return forbidden unless @page.permit_write?(current_user)
    @page.update_attribute :archived, false    
    render :json => @page.to_hash

  rescue ActiveRecord::StaleObjectError => e
    result_conflict
  end

  private
  def load_pages(finder)
    @pages = finder.includes(:user).limit(PER_PAGE)
    @total_pages = finder.count
    @current_index = false

    if params[:old]
      @pages = @pages.where('pages.modified_at < ?', params[:old].to_i).order('pages.modified_at DESC').load
    elsif params[:new]
      @pages = @pages.where('pages.modified_at > ?', params[:new].to_i).order('pages.modified_at ASC').load.sort do |a, b|
        b.modified_at <=> a.modified_at
      end
    else
      @pages = @pages.order('pages.modified_at DESC').load
      @current_index = 0
    end
    @current_index ||= @pages.first ? finder.where('pages.modified_at > ?', @pages.first.modified_at).order('pages.modified_at DESC').count : 0
  end

  private
  def render_pages(old_pages_url: nil, new_pages_url: nil, pages: nil, options: {})
    pages ||= @pages.map { |p| p.to_hash(user: current_user, body: false) }
    @current_index ||= 0
    respond_to do |format|
      format.json do
        render json: { 
          index: @current_index,
          total_pages: @total_pages,
          old_pages_url: @current_index + @pages.count < @total_pages ? old_pages_url.call : nil,
          new_pages_url: @current_index > 0 ? new_pages_url.call : nil,
          pages: pages
        }.merge(options)
      end
    end
  end

  private
  def forbidden
    head 403
  end

  private
  def not_found
    head 404
  end

  private
  def delay_for_test
    sleep @@_delay if @@_delay
  end

  private
  def prepage_variants
    @page = Page.find_by_key(params[:id])
    return not_found unless @page
    @page_title = @page.title
  end

  private
  def result_conflict
    render :json => @page.to_hash, :status => 409
  end
end
