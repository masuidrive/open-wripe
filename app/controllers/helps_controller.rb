class HelpsController < ApplicationController
  before_action :required_login

  def reset
    current_user.create_default_helps

    respond_to do |format|
      format.json do
        render json: current_user.helps.map(&:to_hash)
      end
    end
  end

  def destroy
    help = current_user.helps.key(params[:id]).first
    help.destroy if help
    head 200
  end
end
