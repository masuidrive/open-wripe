class EvernoteAuthController < ApplicationController
  rescue_from OAuth::Unauthorized, :with => Proc.new { redirect_to '/' }

  def sign_in
    request_token = EvernoteAuth.request_token
    session[:evernote_rt] = request_token
    redirect_to request_token.authorize_url
  end

  def connect
    session[:enconnect] = true
    sign_in
  end

  def callback
    access_token = EvernoteAuth.get_access_token(session[:evernote_rt], params)

    if current_user && session[:enconnect]
      begin
        user = EvernoteUser.connect(access_token, current_user)
      rescue EvernoteUser::AlreadyConnected => e
        session[:evernote_token] = access_token
        @error = :already_connected
      end
      render layout: false
    else
      # sign in
      user = EvernoteUser.auth(access_token)
      session[:authorized_user_id] = user.id
      redirect_to :home
    end
    session[:enconnect] = nil

  rescue => e
    logger.error e.inspect
    logger.error e.backtrace.join(", ")
    flash[:notice] = I18n.t(:failed_facebook_login)
    redirect_to '/'
  end
end
