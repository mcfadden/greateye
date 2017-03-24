class PerformRemoteCleanupWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low

  def perform(camera_id)
    Camera.find(camera_id).perform_remote_cleanup!
  end
end
