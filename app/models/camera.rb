require "net/ftp"
class Camera < ActiveRecord::Base
  include CameraTypes
  include SystemAccess

  acts_as_list

  has_many :camera_events

  scope :ordered, ->{ order(:position) }
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

  def perform_remote_cleanup
    return unless active?
    PerformRemoteCleanupWorker.perform_async(id)
  end

  def perform_remote_cleanup!
    raise NotImplementedError, "You must implement `perform_remote_cleanup!` in your subclass."
  end

  def process_camera_event(*args)
    raise NotImplementedError, "You must implement `process_camera_event!` in your subclass."
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

  def preview_requires_basic_auth?
    false
  end

  def preview_requires_digest_auth?
    false
  end

  def preview_needs_refreshing?
    true
  end
end
