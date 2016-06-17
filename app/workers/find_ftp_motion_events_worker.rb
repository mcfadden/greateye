class FindFtpMotionEventsWorker
  
  include Sidekiq::Worker

  sidekiq_options retry: 1, queue: :low

  def perform(camera_id)
    queues = Sidekiq::Queue.all
    if queues.sum{|q| q.size} > Camera.count + 10
      # We're working through a backlog of some sort, so don't make the problem worse.
      Rails.logger.debug "Queue size over limit. Skipping this job."
      return
    end
    
    
    camera = Camera.find(camera_id)
    
    ftp = camera.connect_to_ftp
    begin
      files = camera.files_via_ftp(ftp)
    
      files.each do |file|
        if (File.basename(file).starts_with?("alarm") || File.basename(file).starts_with?("MDalarm")) && file.ends_with?(".avi")
          # If there's a file with a ".avi_idx" extension then it's currently recording that .avi
          # ex: alarm_20150422_081443.avi_idx
      
          #puts "Checking for #{file}_idx"
          if files.include?("#{file}_idx")
            #puts "Currently recording #{file}. Skipping"
            next
          end
      
          ProcessFtpMotionEventWorker.perform_async(camera_id, file)
      
        elsif File.basename(file) == "index.dat"
          # Just ignoring these, but I might delete them some day.
        end
      end
    ensure
      ftp.close
    end
  end
end