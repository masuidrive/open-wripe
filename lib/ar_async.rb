require 'base64'
require 'aws-sdk'

module ActiveRecordAsync
  def self.config
    @config ||= YAML.load(open(File.join(Rails.root, 'config', 'async.yml')))[Rails.env]
  end

  def self.sqs
    @sqs ||= AWS::SQS::Queue.new(ActiveRecordAsync.config['sqs'])
  end

  def async(methodname, args=[])
    message = async_message_dump(methodname, args)
    if ActiveRecordAsync.config['inline']
      ActiveRecordAsync.async_message_run(message)
    else
      if ActiveRecordAsync.async_batch_messages.nil?
        ActiveRecordAsync.sqs.send_message(message)
      else
        ActiveRecordAsync.async_batch_messages << message
      end
    end
  end

  def self.async_batch_messages
    @_async_batch_messages
  end

  def self.async_batch
    @_async_batch_messages = [] if @_async_batch_messages.nil?
    yield
    @_async_batch_messages.each_slice(10) do |messages|
      self.sqs.batch_send(*messages)
    end
  ensure
    @_async_batch_messages = []
  end

  def self.runner
    unless config['inline']
      sqs.poll do |data|
        begin
          message = async_message_run(data.body)
          puts "Got message: #{message[:method]}"
        rescue Exception => e
          p e
        end
      end
    end
  end

  private
  def async_message_dump(methodname, args)
    Base64.encode64(Zlib::Deflate.deflate(Marshal.dump(method: methodname, obj: self, args:args)))
  end

  private
  def self.async_message_run(data)
    message = async_message_load(data)
    message[:result] = message[:obj].send message[:method], *message[:args]
    message
  end

  private
  def self.async_message_load(data)
    Marshal.load(Zlib::Inflate.inflate(Base64.decode64(data)))
  end
end

AWS.config(
  access_key_id: ActiveRecordAsync.config['access_key_id'],
  secret_access_key: ActiveRecordAsync.config['secret_access_key']
)


ActiveRecord::Base.send :include, ActiveRecordAsync
