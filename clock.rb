require 'rubygems'
require 'clockwork'

require './config/boot'
require './config/environment'

module Clockwork
  every(10.minutes, 'tempfiles.clean') { UnlinkStrayTempfilesWorker.perform_async }
  every(1.minute, 'camera.find_new_motion_events'){ Camera.all.each(&:find_and_process_new_motion_events) }
  every(1.hour, 'camera_event.purge_old_events'){ CameraEvent.purge_old_events! }
  every(1.day, 'empty_directories.remove'){ Camera.all.collect(&:id).each{ |id| RemoveEmptyDirectoriesWorker.perform_async(id) } }
end
