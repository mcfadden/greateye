class CronController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  # WARNING: NOTHING IN THIS CONTROLLER IS AUTHENTICATED
  def mark_events_as_failed
    head :ok if CameraEvent.fail_old_events
  end

  def clean_tempfiles
    head :ok if UnlinkStrayTempfilesWorker.perform_async
  end

  def purge_old_events
    head :ok if CameraEvent.purge_old_events
  end

  def find_new_motion_events
    if Sidekiq::Queue.new('low').size > Camera.count * 3
      # We already have a lot of jobs in the low queue
      Rails.logger.debug "Queue size over limit. Skipping this job."
      head :ok and return
    end
    head :ok if Camera.active.each(&:find_camera_events)
  end

  def perform_remote_cleanup
    head :ok if Camera.active.each(&:perform_remote_cleanup)
  end
end
