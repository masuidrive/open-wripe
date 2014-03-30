class AddWhatsnewToHelps < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.helps.create key: 'whatsnew'
    end
  end
end
