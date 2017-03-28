class Camera::Foscam::HdCgi < Camera::Foscam

  def video_events?
    true
  end

  def default_ftp_port
    50021
  end

  def preview_url
    "http://#{host}/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=#{username}&pwd=#{password}"
  end

  def perform_remote_cleanup!
    with_ensure_ftp_close do
      delete_empty_ftp_directories_recursively!
      remove_old_index_dat_files!
    end
  end

  def find_camera_events!
    begin
      files = list_directory(ftp_path_with_default, recursive: true)

      files.each do |file|
        if (File.basename(file).starts_with?("alarm") || File.basename(file).starts_with?("MDalarm")) && file.ends_with?(".avi")
          # If there's a file with a ".avi_idx" extension then it's currently recording that .avi
          # ex: alarm_20150422_081443.avi_idx

          #puts "Checking for #{file}_idx"
          if files.include?("#{file}_idx")
            #puts "Currently recording #{file}. Skipping"
            next
          end

          camera_events.create(remote_id: file) unless camera_events.where(remote_id: file).present?
        end
      end
    ensure
      ftp.close
    end
  end

  def process_camera_event(camera_event)
    tempfile = create_tempfile("camera-#{id.to_s}-")
    file = camera_event.remote_id

    Rails.logger.debug "Fetching file from FTP: #{file}"
    ftp.getbinaryfile(file, tempfile.path)

    #cmd = "ffmpeg -i \"#{temp.path}\" -b:a 128k -vcodec mpeg4 -b:v 1200k -flags +aic+mv4 \"#{temp.path}.mp4\""

    # OLD:

      # # This cmd outputs a video file, and a PNG which is a thumbnail from the 5.5second mark in the video:
      # cmd = "ffmpeg -y -threads '1' -i \"#{tempfile.path}\" \
      #   -map '0:v' -map '0:a' -b:a 128k -vcodec mpeg4 -b:v 1200k -flags +aic+mv4 \"#{tempfile.path}.mp4\" \
      #   -map '0:v' -ss 00:00:5.5 -vframes 1 \"#{tempfile.path}.jpg\""
      #
      # run_shell_command(cmd , "ffmpeg transcode")

    cmd = "ffmpeg -i \"#{tempfile.path}\" -vcodec copy -acodec libfdk_aac -b:a 128k \"#{tempfile.path}.mp4\"  && ffmpeg -ss 00:00:5.5 -i \"#{tempfile.path}\" -vframes 1 \"#{tempfile.path}.jpg\""
    run_shell_command(cmd , "ffmpeg transcode")

    output_video_path = "#{tempfile.path}.mp4"
    thumbnail_path = "#{tempfile.path}.jpg"

    Rails.logger.debug "Transcoded Video path:  #{output_video_path}"
    Rails.logger.debug "Created Thumbnail path: #{thumbnail_path}"

    raise "Missing output video" unless File.exists?(output_video_path)
    raise "Missing thumbnail" unless File.exists?(thumbnail_path)

    Rails.logger.debug "Calculating duration"
    cmd = "ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 \"#{tempfile.path}.mp4\""
    duration = run_shell_command(cmd, "ffprobe duration")

    Rails.logger.debug "Creating camera event"
    # Create the motion event
    time_string = File.basename(file).gsub("MDalarm_", "").gsub("alarm_", "").gsub(".avi", "")
    timestamp = DateTime.strptime(time_string, "%Y%m%d_%H%M%S")

    camera_event.event_timestamp = timestamp
    camera_event.duration        = duration.to_i if duration.to_i > 0
    camera_event.save

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

    if SystemSetting.read_only_mode
      Rails.logger.debug "READ ONLY MODE. Skippping delete for #{file} from FTP server"
    else
      Rails.logger.debug "Deleting #{file} from FTP server"
      ftp.delete(file)
    end
  rescue Net::FTPPermError => ex
    puts ex
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

  def remove_old_index_dat_files!
    all_ftp_files.each do |file|
      next unless File.basename(file) == "index.dat"
      modified_time = ftp.mtime(file)
      # Delete them if they're older than 2 days, but less than 30 days old.
      # 30 days just to prevent something if a clock gets set to last year or something. ¯\_(ツ)_/¯
      if modified_time < 2.days.ago && modified_time > 30.days.ago
        Rails.logger.debug("Old index.dat.. deleting #{file}")
        ftp.delete(file) unless SystemSetting.read_only_mode
      end
    end
  end

end
