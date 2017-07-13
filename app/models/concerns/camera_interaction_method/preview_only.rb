module Concerns::CameraInteractionMethod::PreviewOnly
  extend ActiveSupport::Concern

  def perform_remote_cleanup!
    false
  end

  def find_camera_events!
    false
  end
end
