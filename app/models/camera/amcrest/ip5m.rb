class Camera::Amcrest::Ip5m < Camera::Amcrest
  def video_events?
    true
  end

  def preview_url
    "http://#{host}/cgi-bin/snapshot.cgi?channel=1"
  end

  def preview_requires_digest_auth?
    true
  end

  def preview_needs_refreshing?
    true
  end

  def perform_remote_cleanup!
    with_ensure_ftp_close do
      remove_old_idx_files!
      delete_empty_ftp_directories_recursively!
    end
  end

  def find_camera_events!
    with_ensure_ftp_close do
      files = list_directory(ftp_path_with_default, recursive: true)
      files.each do |file|
        if file.ends_with?('.mp4')
          camera_events.create(remote_id: file) unless camera_events.where(remote_id: file).present?
        end
      end
    end
  end

  private

  def timestamp_from_file(file:)
    Rails.logger.debug "Calculating Event Timestamp"
    # %Y-%m-%d
    date_string = file.split('/').find{ |p| p.starts_with?('20') && p.count('-') == 2 }

    # %H.%M.%S
    time_string = File.basename(file).split('-').first
    timestamp = DateTime.strptime("#{date_string}_#{time_string}", "%Y-%m-%d_%H.%M.%S")
    return timestamp
  end
end
