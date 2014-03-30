class AddUserAgentToFeedbacks < ActiveRecord::Migration
  def change
    add_column :feedbacks, :user_agent, :text
  end
end
