class SessionsController < ApplicationController
  before_action :required_login, only: [:show]
  
  def show
    current_user.helps.clear(:mobile) if request.user_agent && request.user_agent.downcase.include?('mobile')
    current_user.update_attribute :actived_at, Time.now

    show_updates = false
    if (params[:version] || 0).to_i == WRIPE_VERSION && (current_user.properties['version'] || 0).to_i < WRIPE_VERSION
      current_user.properties['version'] = WRIPE_VERSION
      show_updates = true
    end

    a = current_user.properties.where(:key => %w(export-key autosave)).map{|p| [p.key, p.value]}
    props = Hash[a]
    %w(autosave).each do |key|
      if props[key]
        props[key] = %w(t true y yes).include?(props[key].downcase)
      end
    end
    
    render json: {
      user: current_user.to_hash,
      pages_count: current_user.pages.count, 
      csrf_param: request_forgery_protection_token,
      csrf_token: form_authenticity_token,
      helps: current_user.helps.map(&:to_hash),
      properties: props,
      show_updates: show_updates
    }
  end

  def destroy
    reset_session
    render :layout => false
  end
  
  if %w(test development).include?(Rails.env)
    def test
      if params[:username]
        session[:authorized_user_id] = User.find_by_username(params[:username]).id
        flash[:notice] = nil
        redirect_to :home
      else
        render :layout => false
      end
    end
  end
end
