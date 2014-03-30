require "#{Rails.root}/lib/fbauth"

class FbauthController < ApplicationController
  rescue_from OAuth::Unauthorized, :with => Proc.new { redirect_to '/' }

  def sign_in
    redirect_to FbAuth.oauth.url_for_oauth_code(:permissions => "email")
  end

  def callback
    user = FbUser.auth(FbAuth.oauth.get_access_token(params[:code]))
    session[:authorized_user_id] = user.id
    flash[:notice] = nil
    redirect_to :home
  rescue => e
    logger.error e.inspect
    flash[:notice] = I18n.t(:failed_facebook_login)
    redirect_to '/'
  end
end
