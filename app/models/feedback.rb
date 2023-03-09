require './lib/paperclip_ext'
require 'base64'

class Feedback < ApplicationRecord
  belongs_to :user
  if %w(production).include?(Rails.env)
    has_attached_file :image, :storage => :s3, :s3_credentials => "#{Rails.root}/config/paperclip_feedbacks_s3.yml"
  else
    has_attached_file :image
  end

  SUBJECT_LABELS = ['Other', 'Bug', "Idea"]
 
  def image_data=(b64data)
    # remove image/png:base,
    data = Base64.decode64(b64data.split(',').pop)
    self.image = Paperclip::string_to_file('image.png', 'image/png', data)
  end
end
