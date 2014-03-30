#
require 'dropbox-api'
require 'zip/zip'
require './lib/backup_pages'


dbconfig = YAML.load(open(File.join(Rails.root, 'config', 'dropbox.yml')))[Rails.env]

Dropbox::API::Config.app_key = dbconfig['app_key']
Dropbox::API::Config.app_secret = dbconfig['app_secret']
Dropbox::API::Config.mode = dbconfig['mode']


class DropboxBackup
  BACKUP_AGE = 14

  def self.backups
    DropboxUser.includes(:user).each do |dbuser|
      user = dbuser.user
      if user.pages.where('pages.updated_at > ?', 1.days.ago).count > 0
        if backup(user)
          puts "OK: #{user.id}"
        else
          puts "NG: #{user.id}"
        end
      end
    end
  end

  def self.backup(user)
    return false unless user.dropbox_user

    zipfile = BackupPages.zip(user)
    client = Dropbox::API::Client.new :token => user.dropbox_user.auth_token, :secret => user.dropbox_user.auth_secret
    begin
      client.mkdir 'backups'
    rescue Dropbox::API::Error::Forbidden
      # no op
    end

    filename = "backups/wripe.backup.#{Time.now.strftime('%Y-%m-%d')}.zip"
    client.upload filename, open(zipfile).read

    backups = JSON.parse(user.dropbox_user.backups || '[]').push(filename)
    if backups.length > BACKUP_AGE
      file = client.file(backups.unshift)
      file.destroy if file
      user.dropbox_user.update_attribute :backups, JSON.generate(backups)
    end
    true
  rescue Exception => e
    puts e
    puts e.backtrace.join("\n")
    false
  ensure
    FileUtils.rm_rf zipfile if zipfile && File.exists?(zipfile)
  end

  def consumer
    @consumer ||= Dropbox::API::OAuth.consumer(:authorize)
  end

  def request_auth(callback)
    request_token = consumer.get_request_token
    return request_token.authorize_url(oauth_callback: callback), {
      oauth_token: request_token.token,
      oauth_token_secret: request_token.secret
    }
  end

  def authorize(oauth_token, hash)
    request_token = OAuth::RequestToken.from_hash(consumer, hash)
    request_token.get_access_token(:oauth_verifier => oauth_token)
  end

  def remove_old_backup
    client = Dropbox::API::Client.new :token => user.dropbox_user.auth_token, :secret => user.dropbox_user.auth_secret
    file = client.file("backups/wripe.backup.#{BACKUP_AGE.days.ago.to_time.strftime('%Y-%m-%d')}.zip")
    file.destroy if file

    file = client.file("wripe.backup.#{BACKUP_AGE.days.ago.to_time.strftime('%Y-%m-%d')}.zip")
    file.destroy if file

    true
  end
end
