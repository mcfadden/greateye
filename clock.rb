require 'rubygems'
require 'clockwork'

require './config/boot'
require './config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"

    if job == 'minutely.job'
      Camera.all.each(&:find_and_process_new_motion_events)
    elsif job == 'hourly.job'
      CameraEvent.purge_old_events!
    end

  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

  every(1.minutes, 'minutely.job')
  every(1.hour, 'hourly.job')
  #every(10.minutes, 'ten-minutely.job')
  # every(30.minutes, 'GeocodeAnalyticsEvents')
  #
  # every(1.hour, 'MorningSystemStatusCheck', at: '15:00') # 8am MST
  # every(5.minutes, 'SystemStatusCheck')
end
