#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'sunspot/solr/railtie'

Wripe::Application.load_tasks

desc 'deploy to heroku'
task :deploy do
  sh 'git push heroku master'
end

desc 'backup'
task :backup => [:environment] do
  require "#{Rails.root}/lib/backup_dropbox"
  DropboxBackup.backups
end

desc 'queue runner'
task :queue_runner => [:environment] do
  unless Settings.flags.disable_ar_async
    # load for ActiveRecord::ConnectionAdapters::TransactionState
    ActiveRecord::ConnectionAdapters::ClosedTransaction
    ActiveRecordAsync.runner
  end
end

desc 'test on browsers'
task :browsers do
  %w(chrome safari firefox phone tablet).each do |driver|
  #%w(chrome safari firefox ie).each do |driver|
    sh "rake DRIVER=#{driver}"
  end
end
