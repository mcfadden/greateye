class ProcessFtpMotionEventWorker
  include Sidekiq::Worker

  sidekiq_options retry: 1
  
  def perform(camera_id, ftp_file)
    camera = Camera.find(camera_id)
    file = ftp_file
    
    ftp = camera.connect_to_ftp
    
    tempfile = create_tempfile("camera-#{camera.id.to_s}-")
    
    ftp.getbinaryfile(file, tempfile.path)

    #cmd = "ffmpeg -i \"#{temp.path}\" -b:a 128k -vcodec mpeg4 -b:v 1200k -flags +aic+mv4 \"#{temp.path}.mp4\""
    
    
    # OLD:
    
      # # This cmd outputs a video file, and a PNG which is a thumbnail from the 5.5second mark in the video:
      # cmd = "ffmpeg -y -threads '1' -i \"#{tempfile.path}\" \
      #   -map '0:v' -map '0:a' -b:a 128k -vcodec mpeg4 -b:v 1200k -flags +aic+mv4 \"#{tempfile.path}.mp4\" \
      #   -map '0:v' -ss 00:00:5.5 -vframes 1 \"#{tempfile.path}.jpg\""
      #
      # run_shell_command(cmd , "ffmpeg transcode")
    
    cmd = "ffmpeg -i \"#{tempfile.path}\" -vcodec copy -acodec libfaac -b:a 128k \"#{tempfile.path}.mp4\"  && ffmpeg -ss 00:00:5.5 -i \"#{tempfile.path}\" -vframes 1 \"#{tempfile.path}.jpg\""
    run_shell_command(cmd , "ffmpeg transcode")
    
    output_video_path = "#{tempfile.path}.mp4"
    thumbnail_path = "#{tempfile.path}.jpg"
    
    Rails.logger.debug "Transcoded Video path:  #{output_video_path}"
    Rails.logger.debug "Created Thumbnail path: #{thumbnail_path}"
    
    Rails.logger.debug "Creating camera event"
    # Create the motion event
    time_string = File.basename(file).gsub("MDalarm_", "").gsub("alarm_", "").gsub(".avi", "")
    timestamp = DateTime.strptime(time_string, "%Y%m%d_%H%M%S")
    
    if camera.camera_events.where(event_timestamp: timestamp).count > 0
      # This event already exists.
      camera_event = camera.camera_events.where(event_timestamp: timestamp).first
      # We're going to delete the assets we have on file, as we're likely here due to processing failing.
      camera_event.camera_event_assets.destroy_all
    else
      camera_event = camera.camera_events.create(event_timestamp: timestamp)
    end
  
  
  
    Rails.logger.debug "Creating video event asset"
    # Create an asset for the video
    event_asset = camera_event.camera_event_assets.build
    event_asset.update_attributes(
      asset_filename: "#{time_string}.mp4",
      asset_file_path: "#{event_asset.asset_key}/#{time_string}.mp4",
      asset_size: File.size(output_video_path),
      asset_original_filename: nil,
      asset_stored_privately: true,
      asset_type: "video/mp4"
    )
    # Copy the transcoded file to S3
    cmd = "AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY']}  AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_KEY']}  aws s3 --region us-east-1 cp \"#{output_video_path}\" \"s3://#{ENV['AWS_BUCKET']}/#{event_asset.asset_file_path}\" --acl private"
    run_shell_command( cmd, "Copy video file to S3" )
    
    event_asset.complete!
      
    Rails.logger.debug "Creating thumbnail event asset"  
    # Create an asset for a thumbnail
    event_asset = camera_event.camera_event_assets.build
    event_asset.update_attributes(
      asset_filename: "#{time_string}.jpg",
      asset_file_path: "#{event_asset.asset_key}/#{time_string}.jpg",
      asset_size: File.size(thumbnail_path),
      asset_original_filename: nil,
      asset_stored_privately: true,
      asset_type: "image/jpeg"
    )
    # Copy the thumbnail to S3
    cmd = "AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY']}  AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_KEY']}  aws s3 --region us-east-1 cp \"#{thumbnail_path}\" \"s3://#{ENV['AWS_BUCKET']}/#{event_asset.asset_file_path}\" --acl private"
    run_shell_command( cmd, "Copy thumbnail file to S3" )
    
    event_asset.complete!
      
    camera_event.complete!
  
    Rails.logger.debug "Deleting #{file} from FTP server"
    ftp.delete(file)
  rescue Net::FTPPermError => ex
    return if ex.message.include?("No such file or directory")
  ensure
    ftp.close
  
    # delete the transcoded file and thumbnail
    File.delete(output_video_path) if defined?(output_video_path) && output_video_path && File.exist?(output_video_path)
    File.delete(thumbnail_path) if defined?(thumbnail_path) && thumbnail_path && File.exist?(thumbnail_path)
  
    # release the tmp file
    Rails.logger.debug "Deleting tempfile"
    tempfile.close
    tempfile.unlink
    File.delete(tempfile.path) if tempfile.path && File.exist?(tempfile.path)
    tempfile = nil # Grasping at straws
  end
  
  def create_tempfile(prefix)
    return Tempfile.new(prefix, Rails.root.join('tmp').join('camera-event-assets') )
  end
  
  def run_shell_command( cmd, desc = "", raise_error_on_fail = true )
    #puts cmd
    output = `#{cmd} 2>&1`
    status = $?.exitstatus

    #puts "Output:\n#{output}"
    #puts "Status:\n#{status}"

    raise "#{desc} failed. #{output}" if status != 0 && raise_error_on_fail
  end
end