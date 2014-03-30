require "#{Rails.root}/lib/ghauth"

class GhauthController < ApplicationController
  rescue_from OAuth::Unauthorized, :with => Proc.new { redirect_to '/' }
  
  def sign_in
    redirect_to GhAuth.oauth.authorize_url(client_id: GhAuth.config['client_id'], scope: 'user:email')
  end

  def callback
    token = GhAuth.oauth.auth_code.get_token(params[:code])
    logger.error token
    logger.error token.token
    user = GhUser.auth(token.token)
    session[:authorized_user_id] = user.id
    flash[:notice] = nil
    redirect_to :home
  rescue => e
    logger.error e.inspect
    flash[:notice] = I18n.t(:failed_facebook_login)
    redirect_to '/'
  end
end
