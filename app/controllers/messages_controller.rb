class MessagesController < ApplicationController
  before_action :required_login
  PER_PAGE = 10

  def index
    load_messages current_user.messages
    render_messages \
      old_messages_url: -> { "/messages.json?old=#{@messages.last.modified_at}" },
      new_messages_url: -> { "/messages.json?new=#{@messages.first.modified_at}" }
  end


  private
  def load_messages(finder)
    @messages = finder.includes(:page, :user).limit(PER_PAGE)
    @total_messages = finder.count
    @current_index = false

    if params[:old]
      @messages = @messages.where('user_messages.created_at < ?', params[:old].to_i).order('user_messages.created_at DESC').load
    elsif params[:new]
      @messages = @messages.where('user_messages.created_at > ?', params[:new].to_i).order('user_messages.created_at ASC').load.sort do |a, b|
        b.modified_at <=> a.modified_at
      end
    else
      @messages = @messages.order('user_messages.created_at DESC').load
      @current_index = 0
    end
    @current_index ||= finder.where('user_messages.created_at > ?', @messages.first.modified_at).order('user_messages.created_at DESC').count 
  end

  private
  def render_messages(old_messages_url: nil, new_messages_url: nil, messages: nil, options: {})
    messages ||= @messages.map { |p| p.to_hash(user: current_user, body: false) }
    @current_index ||= 0
    respond_to do |format|
      format.json do
        render json: { 
          index: @current_index,
          total_messages: @total_messages,
          old_messages_url: @current_index + @messages.count < @total_messages ? old_messages_url.call : nil,
          new_messages_url: @current_index > 0 ? new_messages_url.call : nil,
          messages: messages.map(&:to_hash)
        }.merge(options)
      end
    end
  end

end
