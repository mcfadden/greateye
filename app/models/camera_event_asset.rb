class CameraEventAsset < ActiveRecord::Base
  belongs_to :camera_event
  
  anaconda_for :asset, base_key: :asset_key
  
  enum status: {
    processing: 0,
    complete: 1
  }

  scope :thumbnails, ->{ where(asset_type: "image/jpeg" ) }
  scope :videos, ->{ where(asset_type: "video/mp4" ) }

  def asset_key
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    s = (0...8).map { o[rand(o.length)] }.join
    "camera_event_assets/#{camera_event.camera.name.downcase.underscore}/#{camera_event.event_timestamp.strftime('%Y_%m_%d')}/#{camera_event.event_timestamp.strftime('%H%M%S')}_#{s}"
  end
end
