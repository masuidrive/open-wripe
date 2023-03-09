class ApplicationController < ActionController::Base
  protect_from_forgery
  around_action :active_record_queue_filter if !Settings.flags.disable_ar_async

  private
  def required_login
    unless current_user
      respond_to do |format|
        format.html { redirect_to '/' }
        format.json { head 401 }
      end
    end
    true
  end

  private
  def required_admin
    return true if Rails.env == 'development'
    unless current_user && current_user.is_admin?
      respond_to do |format|
        format.html { head 404 }
      end
    end
    true
  end

  private
  def current_user
    return @current_user if @current_user
    return nil if @current_user === false
    user = User.where(:id => session[:authorized_user_id]).first
    @current_user = user && user.active? ? user : false
  end

  private
  def active_record_queue_filter
    ActiveRecordAsync.async_batch do
      yield
    end
  end

  private
  def handle_unverified_request
    # reset_session
    raise ActionController::InvalidAuthenticityToken
  end
  
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    respond_to do |format|
      format.html do
        redirect_to '/'
      end
      format.json do
        head :precondition_failed
      end
    end
  end
end
