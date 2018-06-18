class Admin::StatsController < Admin::BaseController
  def index
    @storage_per_camera = CameraEventAsset.joins(:camera_event).group('camera_events.camera_id').sum(:asset_size)
    oldest_event_timestamp = CameraEvent.ordered.unkept.where.not(event_timestamp: nil).last.event_timestamp || 30.days.ago
    @grouped_events = CameraEvent.group_by_day(:event_timestamp, range: (oldest_event_timestamp..Time.now), format: "%m-%d").count
    @grouped_event_storage = CameraEventAsset
      .joins(:camera_event)
      .group_by_day(:event_timestamp, range: (oldest_event_timestamp..Time.now), format: "%m-%d")
      .sum(:asset_size)
      .map{ |k, v| [k, (v.to_f / 1.megabyte).round]}
      .to_h
  end
end
