class Camera::Foscam::HdCgi < Camera::Foscam
  include Concerns::CameraEventVideoProcessing::FfmpegH264Source
  include Concerns::CameraEventVideoProcessing::SingleVideoFile

  def video_events?
    true
  end

  def default_ftp_port
    50021
  end

  def preview_url
    "http://#{host}/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=#{username}&pwd=#{password}"
  end

  def preview_needs_refreshing?
    true
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
    rescue Errno::ECONNREFUSED
      Rails.logger.info "Errno::ECONNREFUSED when connecting to Camera #{self.id}"
      return false
    ensure
      ftp.close
    end
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

  private
  def timestamp_from_file(file:)
    Rails.logger.debug "Calculating Event Timestamp"
    time_string = File.basename(file).gsub("MDalarm_", "").gsub("alarm_", "").gsub(".avi", "")
    timestamp = DateTime.strptime(time_string, "%Y%m%d_%H%M%S")
    return timestamp
  end
end
