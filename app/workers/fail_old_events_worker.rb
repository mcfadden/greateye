class FailOldEventsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low

  def perform
    return unless SystemSetting.find_new_events_enabled
    CameraEvent.fail_old_events!
  end
end
