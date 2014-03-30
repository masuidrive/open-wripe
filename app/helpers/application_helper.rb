module ApplicationHelper
  def current_user
    controller.current_user
  end

  def render_top_nav(&block)
    body = block ? capture(&block) : ''
    render 'shared/top_nav', :body => body
  end

  def render_dialog(id, title, cancel:'Close', cancel_class:'', action:nil, &block)
    render :partial => 'shared/dialog', locals: { id: id, title: title, cancel_class: cancel_class, cancel_label: cancel, action: action, body_block: block }
  end

  def render_help(id, title, &block)
    render :partial => 'shared/help', locals: { id: id, title: title, body_block: block }
  end 
end
