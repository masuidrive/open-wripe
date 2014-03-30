module GhAuth
  def self.config
    @config ||= YAML.load(open(File.join(Rails.root, 'config', 'github.yml')))[Rails.env]
  end

  def self.oauth
    @oauth ||=  OAuth2::Client.new(config['client_id'], config['client_secret'], {
      site: 'https://api.github.com',
      authorize_url: 'https://github.com/login/oauth/authorize',
      token_url: 'https://github.com/login/oauth/access_token'
    })
  end
end