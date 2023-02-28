class RemoveExpirationFormEvernoteUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :evernote_users, :expiration
  end
end
