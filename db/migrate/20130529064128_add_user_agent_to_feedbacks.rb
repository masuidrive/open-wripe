class AddUserAgentToFeedbacks < ActiveRecord::Migration[4.2]
  def change
    add_column :feedbacks, :user_agent, :text
  end
end
