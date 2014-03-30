class Pages::MembersController < ApplicationController
  before_filter :required_login
  before_filter :prepage_variants

  def index
    @page_users = @page.page_users
    render_page_user
  end

  def create
    @page_user = @page.page_users.create params[:user]
    render_page_user
  end

  def show
    @page_user = @page.page_users.where(params[:id]).first
    render_page_user
  end

  def update
    @page_user = @page.page_users.where(params[:id]).first
    @page_user.update_attributes params[:permission]
    render_page_user
  end

  def destroy
    @page.page_users.where(params[:user][:id]).first.destroy
    head 200
  end

  private
  def render_page_user
    respond_to do |format|
      format.html
      format.json {
        if @page_users
          render :json => { :owner => @page.user.to_hash, :users => @page_users.map(&:to_hash) }
        else
          render :json => @page_user.to_hash
        end
      }
    end
  end

  private
  def forbidden
    head 403
  end

  private
  def prepage_variants
    @page = Page.find_by_key(params[:page_id])
    return forbidden unless @page.permit_share?(current_user)
  end
end
