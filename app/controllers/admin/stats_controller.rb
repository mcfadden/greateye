class Admin::StatsController < Admin::BaseController
  def index
    @storage_per_camera = CameraEventAsset.joins(:camera_event).group('camera_events.camera_id').sum(:asset_size)
  end
end
