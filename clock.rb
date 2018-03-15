require 'rubygems'
require 'net/http'
require 'clockwork'

HOST = ENV['CLOCKWORK_HOST'] || '127.0.0.1'

module Clockwork
  handler do |job|
    begin
      http = Net::HTTP.new(HOST, 80)
      request = Net::HTTP::Post.new("/cron/#{job}")
      http.request(request)
    rescue Net::ReadTimeout
      # Don't crash clockwork
    end
  end

  every(1.minute, 'find_new_motion_events')
  every(10.minutes, 'clean_tempfiles')

  every(1.hour, 'purge_old_events')
  every(1.hour, 'mark_events_as_failed')
  every(12.hours, 'perform_remote_cleanup')
end
