class GhUser < ApplicationRecord
  belongs_to :user

  def self.auth(ghtoken)
    gh = Octokit::Client.new(access_token: ghtoken)
    profile = gh.user
    ghid = profile['id'].to_s
    ghuser = GhUser.where(:ghid => ghid).first
    unless ghuser
      ghuser = GhUser.create! :token => ghtoken, :ghid => ghid, :json => JSON.generate(profile)
    end
    user = ghuser.user
    unless user
      username = profile['login']
      while User.where(:username => username).count > 0
        username += rand(10).to_s
      end
      user = User.create! :username => username
      ghuser.update_attributes :user_id => user.id
    end
    
    user.update_attributes :icon_url => profile['avatar_url']
    email = gh.emails.first rescue nil
    user.update_attributes :email => email unless email.blank?
    user
  end
end
