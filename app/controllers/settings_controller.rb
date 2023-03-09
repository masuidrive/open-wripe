class SettingsController < ApplicationController
  before_action :required_login

  def show
    respond_to do |format|
      format.html
      format.json do
        render json: { 
          use_dropbox: !!current_user.dropbox_user,
          use_evernote: !!current_user.evernote_user
        }
      end
    end
  end

  def update
    if params[:use_dropbox] == 'false'
      current_user.dropbox_user.destroy if current_user.dropbox_user
    end

    if params[:use_evernote] == 'false'
      current_user.evernote_user.destroy if current_user.evernote_user
      session[:enconnect] = nil
      session[:evernote_token] = nil
    end

    unless params[:autosave].nil?
      current_user.properties[:autosave] = (params[:autosave] == 'true')
    end

    respond_to do |format|
      format.html { redirect_to :show }
      format.json do
        render json: { 
          use_dropbox: !!current_user.dropbox_user,
          use_evernote: !!current_user.evernote_user
        }
      end
    end
  end # update

end
