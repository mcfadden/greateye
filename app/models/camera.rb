require "net/ftp"
class Camera < ActiveRecord::Base
  include CameraTypes

  has_many :camera_events

  scope :active, ->{ where(active: true) }

  after_initialize :become_type_for_make_and_model

  def self.discriminate_class_for_record(record)
    unless self.class == Camera || record['make'].nil? || record['model'].nil?
      Camera.type_for(make: record['make'], model: record['model'])
    else
      super
    end
  end

  def become_type_for_make_and_model
    return unless self.class == Camera
    return if make.nil? || model.nil?
    self.becomes(Camera.type_for(make: make, model: model))
  end

  def find_camera_events
    return unless active?
    FindCameraEventsWorker.perform_async(id)
  end

  def find_camera_events!
    raise NotImplementedError, "You must implement `find_camera_events!` in your subclass."
  end

  def find_and_process_new_motion_events
    FindFtpMotionEventsWorker.perform_async(id) if can_record_events?
  end


  def video_events?
    false
  end

  def preview_url
    false
  end

  def default_ftp_port
    nil
  end

end
