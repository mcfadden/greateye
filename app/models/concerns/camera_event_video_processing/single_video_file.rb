module Concerns::CameraEventVideoProcessing::SingleVideoFile
  extend ActiveSupport::Concern

  def create_camera_event_assets(input:, camera_event:)
    input_video_path = input
    output_video_path = "#{input_video_path}.mp4"
    output_thumbnail_pattern = "#{input_video_path}-thumbnail"

    convert_file_to_mp4(source: input_video_path, destination: output_video_path)
    Rails.logger.debug "Transcoded Video path:  #{output_video_path}"

    export_thumbnails(source: input_video_path, destination_pattern: output_thumbnail_pattern)
    Rails.logger.debug "Thumbnail pattern path: #{output_thumbnail_pattern}"

    duration = duration_for_video(source: output_video_path)
    Rails.logger.debug "Duration found to be #{duration}"
    # if it's over an hour, it's a malformed video. It happens
    camera_event.duration = duration.to_i if duration.to_i > 0 && duration.to_i < 1.hour

    camera_event.save

    Rails.logger.debug "Creating video event asset"
    # Create an asset for the video
    video_event_asset = camera_event.camera_event_assets.build
    video_event_asset.import_file_to_anaconda_column(output_video_path, :asset)
    video_event_asset.update( asset_type: "video/mp4" )
    video_event_asset.complete!

    # Create an asset for each thumbnail
    Rails.logger.debug "Creating thumbnail event assets"
    thumbnail_files = Dir.glob("#{output_thumbnail_pattern}*")
    thumbnail_files.each do |output_thumbnail_path|
      Rails.logger.debug "Creating thumbnail event asset for #{output_thumbnail_path}"
      thumbnail_event_asset = camera_event.camera_event_assets.build
      thumbnail_event_asset.import_file_to_anaconda_column(output_thumbnail_path, :asset)
      thumbnail_event_asset.update( asset_type: "image/jpeg" )
      thumbnail_event_asset.complete!
    end
  end
end
