class FbUser < ActiveRecord::Base
  belongs_to :user

  def self.auth(fbtoken)
    graph = Koala::Facebook::API.new(fbtoken)
    fb_profile = graph.get_object("me")
    fbid = fb_profile['id']
    fbuser = FbUser.find_by_fbid(fbid)
    unless fbuser
      fbuser = FbUser.create :token => fbtoken, :fbid => fbid, :json => JSON.generate(fb_profile)
    end
    user = fbuser.user
    unless user
      username = fb_profile['username'] || fb_profile['first_name'].gsub(/\W/,'')[0,14].downcase
      while User.where(:username => username).count > 0
        username += rand(10).to_s
      end
      user = User.create :username => username
      fbuser.update_attributes :user_id => user.id
    end
    user.update_attributes :icon_url => graph.get_picture(fb_profile['id'])
    user.update_attributes :email => fb_profile['email'] if user.email.blank?
    user
  end
end
