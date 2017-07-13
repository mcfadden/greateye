class PurgeOldEventsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low

  def perform
    CameraEvent.purge_old_events!
  end
end
