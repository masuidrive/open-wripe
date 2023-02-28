require "#{Rails.root}/lib/backup_dropbox"

class DropboxAuthController < ApplicationController
  before_action :required_login

  def sign_in
    url, session[:dropbox] = DropboxBackup.new.request_auth(Rails.application.routes.url_helpers.dropbox_auth_callback_url)
    redirect_to url
  end

  def callback
    result = DropboxBackup.new.authorize(params[:oauth_token], session[:dropbox])
    dbuser = (current_user.dropbox_user || current_user.create_dropbox_user)
    dbuser.update_attributes auth_token: result.token, auth_secret: result.secret
    current_user.helps.clear 'backup'
  end
end
