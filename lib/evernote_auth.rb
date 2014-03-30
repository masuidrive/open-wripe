require 'evernote_oauth'

module EvernoteAuth
  def self.config
    @config ||= YAML.load(open(File.join(Rails.root, 'config', 'evernote.yml')))[Rails.env]
  end

  def self.oauth(token=nil)
    EvernoteOAuth::Client.new(
      token: token,
      consumer_key: config['consumer_key'],
      consumer_secret: config['consumer_secret'],
      sandbox: config['sandbox']
    )
  end

  def self.request_token
    EvernoteAuth.oauth.request_token(oauth_callback: config['callback'])
  end

  def self.get_access_token(request_token, params)
    request_token.get_access_token(oauth_verifier: params[:oauth_verifier]).token
  end
end