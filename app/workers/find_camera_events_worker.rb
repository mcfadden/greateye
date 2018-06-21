class FindCameraEventsWorker

  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: :low

  def perform(camera_id)
    return unless SystemSetting.find_new_events_enabled
    camera = Camera.find(camera_id)
    camera.find_camera_events!
  end
end
