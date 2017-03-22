class FindCameraEventsWorker

  include Sidekiq::Worker

  sidekiq_options retry: 0, queue: :low

  def perform(camera_id)
    queues = Sidekiq::Queue.all
    if queues.sum{|q| q.size} > Camera.count * 3
      # We're working through a backlog of some sort, so don't make the problem worse.
      Rails.logger.debug "Queue size over limit. Skipping this job."
      return
    end

    camera = Camera.find(camera_id)
    camera.find_camera_events!
  end
end
