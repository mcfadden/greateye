class UnlinkStrayTempfilesWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :critical
  
  REMOVE_AFTER = 20.minutes
  FILE_LIMIT = 500
  
  def perform
    path = Rails.root.join('tmp').join('camera-event-assets')
    find_and_unlink_old_files_in_path(path)
  end

  def find_and_unlink_old_files_in_path(path)
    Dir.glob("#{path}/*").first(FILE_LIMIT).each do |directory_path|
      if File.directory?(directory_path)
        # This is a directory
        should_delete_directory = true
        Dir.glob("#{directory_path}/*").each do |file_path|
          if !unlink_file_if_old(file_path)
            should_delete_directory = false
          end
        end
      
        if should_delete_directory
          begin
            Dir.unlink(directory_path)
          rescue SystemCallError
            # The directory probably isn't empty. Let's just ignore that for now.
            nil
          end
        end
      else
        # This is a file..
        unlink_file_if_old(directory_path)
      end
    end
  end

  def unlink_file_if_old(file_path)
    if File.ctime(file_path) < (Time.now - REMOVE_AFTER)
      # We're old!
    
      Rails.logger.debug("Unlinking #{file_path}")
      File.unlink(file_path)
      return true
    else
      return false
    end
  end
end