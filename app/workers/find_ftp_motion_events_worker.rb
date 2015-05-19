class FindFtpMotionEventsWorker
  include Sidekiq::Worker

  def perform(camera_id)
    camera = Camera.find(camera_id)
    
    files = camera.files_via_ftp
    
    ftp = camera.connect_to_ftp
    
    files.each do |file|
      if File.basename(file).starts_with?("alarm") && file.ends_with?(".avi")
        # If there's a file with a ".avi_idx" extension then it's currently recording that .avi
        # ex: alarm_20150422_081443.avi_idx
      
        puts "Checking for #{file}_idx"
        if files.include?("#{file}_idx")
          puts "Currently recording #{file}. Skipping"
          next
        end
      
        ProcessFtpMotionEventWorker.perform_async(camera_id, file)
      
      elsif File.basename(file) == "index.dat"
        # Just ignoring these, but I might delete them some day.
      end
    end
  end
end