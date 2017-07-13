class Camera::Reolink < Camera
  include Concerns::CameraInteractionMethod::Ftp
  include Concerns::CameraEventVideoProcessing::FfmpegH264Source
  include Concerns::CameraEventVideoProcessing::SingleVideoFile
  alias_method :single_video_file_create_camera_event_assets, :create_camera_event_assets
  include Concerns::CameraEventVideoProcessing::ThumbnailAndVideoFile
  alias_method :thumbnail_and_video_file_create_camera_event_assets, :create_camera_event_assets

  def video_events?
    true
  end

  def preview_url
    "http://#{host}/cgi-bin/api.cgi?cmd=Snap&channel=0&rs=abc#{rand(12)}&user=#{username}&password=#{password}"
  end

  def preview_needs_refreshing?
    true
  end

  def find_camera_events!
    begin
      files = list_directory(ftp_path_with_default, recursive: true)
      files.each do |file|
        # TODO: This is temporarily limited to the last 24 hours for my testing
        if file.ends_with?(".mp4") && ftp.mtime(file) < 1.minute.ago && ftp.mtime(file) > 24.hours.ago
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

  def process_camera_event(camera_event)
    # Gently modified from the `ftp` version to fetch multiple files
    video_tempfile = create_tempfile("camera-#{id.to_s}-")
    thumbnail_tempfile = create_tempfile("camera-#{id.to_s}-")
    file = camera_event.remote_id

    Rails.logger.debug "Fetching video file from FTP: #{file}"
    ftp.getbinaryfile(file, video_tempfile.path)
    Rails.logger.debug "Fetching thumbnail file from FTP: #{file}"
    ftp.getbinaryfile(file.gsub('mp4', 'jpg'), thumbnail_tempfile.path)

    camera_event.event_timestamp = timestamp_from_file(file: file)

    create_camera_event_assets(camera_event: camera_event, input: video_tempfile.path, thumbnail_input: thumbnail_tempfile.path)

    Rails.logger.debug "Camera Event Complete!"
    camera_event.complete!

    if SystemSetting.read_only_mode
      Rails.logger.debug "READ ONLY MODE. Skipping delete for #{file} from FTP server"
    else
      Rails.logger.debug "Deleting #{file} from FTP server"
      ftp.delete(file)
      Rails.logger.debug "Deleting #{file.gsub('mp4', 'jpg')} from FTP server"
      ftp.delete(file.gsub('mp4', 'jpg'))
    end
  rescue Net::FTPPermError => ex
    Rails.logger.debug "Net::FTPPermError: #{ex.inspect}"
    return if ex.message.include?("No such file or directory")
  ensure
    ftp.close

    Rails.logger.debug "Deleting video tempfile"
    video_tempfile.close
    video_tempfile.unlink
    File.delete(video_tempfile.path) if video_tempfile.path && File.exist?(video_tempfile.path)
    video_tempfile = nil

    Rails.logger.debug "Deleting thumbnail tempfile"
    thumbnail_tempfile.close
    thumbnail_tempfile.unlink
    File.delete(thumbnail_tempfile.path) if thumbnail_tempfile.path && File.exist?(thumbnail_tempfile.path)
    thumbnail_tempfile = nil
  end

  def create_camera_event_assets(input:, thumbnail_input: nil, camera_event:)
    if thumbnail_count <= 1 && thumbnail_input.present?
      # We can use the thumbnail generated by the camera
      thumbnail_and_video_file_create_camera_event_assets(
        input: input,
        thumbnail_input: thumbnail_input,
        camera_event: camera_event
      )
    else
      # Lets generate our own thumbnails
      single_video_file_create_camera_event_assets(
        input: input,
        camera_event: camera_event
      )
    end
  end

  private

  def timestamp_from_file(file:)
    Rails.logger.debug "Calculating Event Timestamp"
    time_string = File.basename(file).split('_').last.gsub(".mp4", "")
    timestamp = DateTime.strptime(time_string, "%Y%m%d%H%M%S")
    return timestamp
  end
end
