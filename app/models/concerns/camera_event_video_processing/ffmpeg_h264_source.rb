module Concerns::CameraEventVideoProcessing::FfmpegH264Source
  extend ActiveSupport::Concern

  def convert_file_to_mp4(source:, destination:)
    cmd = "ffmpeg -i \"#{source}\" -vcodec copy -acodec libfdk_aac -b:a 128k \"#{destination}\""
    run_shell_command(cmd , "ffmpeg convert_file_to_mp4")
  end

  def export_thumbnails(source:, destination_pattern:)
    cmd = "ffmpeg -ss 00:00:#{thumbnail_start_seconds} -i \"#{source}\" -r 1/#{thumbnail_interval_seconds} -vframes #{thumbnail_count} \"#{destination_pattern}-%03d.jpg\""
    run_shell_command(cmd , "ffmpeg export_thumbnails")
  end

  def duration_for_video(source:)
    cmd = "ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 \"#{source}\""
    run_shell_command(cmd, "ffprobe duration")
  end
end
