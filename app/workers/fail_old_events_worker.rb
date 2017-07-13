class FailOldEventsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low

  def perform
    CameraEvent.fail_old_events!
  end
end
