require './lib/backup_pages'

class ExportsController < ApplicationController
  before_filter :required_login

  def zip
    zipfile = BackupPages.zip(current_user)
    send_file zipfile
  end
end
