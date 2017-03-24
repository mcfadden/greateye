require 'rubygems'
require 'clockwork'

require './config/boot'
require './config/environment'

module Clockwork
  # Local cleanup
  every(10.minutes, 'tempfiles.clean') { UnlinkStrayTempfilesWorker.perform_async }

  # Purge old events
  every(1.hour, 'camera_event.purge_old_events'){ CameraEvent.purge_old_events! }

  # Find new motion events
  every(1.minute, 'camera.find_new_motion_events'){ Camera.active.each(&:find_camera_events) }

  # Remote cleanup
  every(1.day, 'empty_directories.remove'){ Camera.active.each(&:perform_remote_cleanup) }
end
