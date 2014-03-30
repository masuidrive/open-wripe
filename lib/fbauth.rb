module FbAuth
  def self.config
    @config ||= YAML.load(open(File.join(Rails.root, 'config', 'facebook.yml')))[Rails.env]
  end

  def self.oauth
    @oauth ||= Koala::Facebook::OAuth.new(config['application_id'], config['application_secret'], config['callback'])
  end
end