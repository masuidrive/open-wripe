class AddEmailToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email, :string
  end
end
