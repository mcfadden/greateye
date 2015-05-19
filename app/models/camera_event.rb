class CameraEvent < ActiveRecord::Base
  belongs_to :camera
  has_many :camera_event_assets, dependent: :destroy
  
  enum event_type: {
    motion: 0
  }
  
  enum status: {
    processing: 0,
    complete: 1
  }
  
  scope :ordered, ->{ order("event_timestamp DESC") }
  scope :kept, ->{ where(keep: true) }
  scope :unkept, ->{ where(keep: false) }
  
  def self.purge_old_events!
    CameraEvent.unkept.where("event_timestamp < ?", 45.days.ago).destroy_all
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
end
