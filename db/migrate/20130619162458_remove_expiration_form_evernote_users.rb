class RemoveExpirationFormEvernoteUsers < ActiveRecord::Migration
  def change
    remove_column :evernote_users, :expiration
  end
end
