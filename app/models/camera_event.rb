class CameraEvent < ActiveRecord::Base
  belongs_to :camera
  has_many :camera_event_assets, dependent: :destroy
  after_commit :process_camera_event, on: :create

  has_one :primary_thumbnail, ->{ merge(CameraEventAsset.thumbnails.ordered) }, class_name: 'CameraEventAsset'
  has_one :primary_video, ->{ merge(CameraEventAsset.videos.ordered) }, class_name: 'CameraEventAsset'

  enum event_type: {
    motion: 0
  }

  enum status: {
    processing: 0,
    complete: 1,
    failed: 2
  }

  scope :ordered, ->{ order("event_timestamp DESC") }
  scope :kept, ->{ where(keep: true) }
  scope :unkept, ->{ where(keep: false) }
  scope :displayable, -> { where.not(event_timestamp: nil) }
  scope :ready_for_purging, ->(camera_id) { where(camera_id: camera_id).unkept.where("event_timestamp < ?", Camera.find(camera_id).purge_after_days.days.ago) }

  def self.purge_old_events
    PurgeOldEventsWorker.perform_async
  end

  def self.purge_old_events!
    Camera.ids.each do |camera_id|
      CameraEvent.ready_for_purging(camera_id).limit(500).each(&:destroy)
    end
  end

  def self.fail_old_events
    FailOldEventsWorker.perform_async
  end

  def self.fail_old_events!
    CameraEvent.processing.where('updated_at < ?', 1.hour.ago).update_all(status: CameraEvent.statuses[:failed])
  end

  def keep!
    self.update_attribute(:keep, true)
  end

  def unkeep!
    self.update_attribute(:keep, false)
  end

  def kept?
    keep?
  end

  def process_camera_event
    ProcessCameraEventWorker.perform_async(id)
  end

  def process_camera_event!
    camera.process_camera_event(self)
  end
end
