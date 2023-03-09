class FeedbacksController < ApplicationController
  before_action :required_admin, except: [:create]

  def create
    @feedback = Feedback.new params.require(:feedback).permit(:body, :image_data, :subject)
    @feedback.user_agent = request.user_agent
    @feedback.user = current_user if current_user
    @feedback.save!

    respond_to do |format|
      format.html { head 201 }
      format.json { render json: [], status: 201 }
    end
  end

  def index
    @feedbacks = Feedback.order('feedbacks.id DESC').page(params[:page])
  end
end
