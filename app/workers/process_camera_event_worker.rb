class ProcessCameraEventWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(camera_event_id)
    camera_event = CameraEvent.find(camera_event_id)
    return unless camera_event.processing?
    camera_event.process_camera_event!
  end
end
