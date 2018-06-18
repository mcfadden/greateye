class Admin::Cameras::StatsController < Admin::BaseController
  def show
    @camera = Camera.find(params[:camera_id])
    first_event_timestamp = @camera.camera_events.ordered.unkept.first.event_timestamp || 30.days.ago
    @grouped_events = @camera.camera_events.group_by_day(:event_timestamp, range: (first_event_timestamp..Time.now), format: "%m-%d").count
    @grouped_event_storage = CameraEventAsset
      .joins(:camera_event)
      .where(camera_events: { camera_id: @camera.id })
      .group_by_day(:event_timestamp, range: (first_event_timestamp..Time.now), format: "%m-%d")
      .sum(:asset_size)
      .map{ |k, v| [k, (v.to_f / 1.megabyte).round]}
      .to_h
  end
end
