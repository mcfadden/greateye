class FindCameraEventsWorker

  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low

  def perform(camera_id)
    camera = Camera.find(camera_id)
    camera.find_camera_events!
  end
end
