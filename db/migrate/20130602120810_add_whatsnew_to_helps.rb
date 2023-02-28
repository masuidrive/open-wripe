class AddWhatsnewToHelps < ActiveRecord::Migration[4.2]
  def up
    User.all.each do |user|
      user.helps.create key: 'whatsnew'
    end
  end
end
