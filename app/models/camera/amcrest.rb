class Camera::Amcrest < Camera
  include Concerns::CameraInteractionMethod::Ftp
  include Concerns::CameraEventVideoProcessing::FfmpegH264Source
  include Concerns::CameraEventVideoProcessing::SingleVideoFile

  private

  def remove_old_idx_files!
    all_ftp_files.each do |file|
      next unless File.extname(file) == ".idx"
      modified_time = ftp.mtime(file)
      # Delete them if they're older than 2 days, but less than 30 days old.
      # 30 days just to prevent something if a clock gets set to last year or something. ¯\_(ツ)_/¯
      if modified_time < 2.days.ago && modified_time > 30.days.ago
        Rails.logger.debug("Old idx.. deleting #{file}")
        ftp.delete(file) unless SystemSetting.read_only_mode
      end
    end
  end
end
