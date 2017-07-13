class Camera::Foscam::Sd < Camera::Foscam
  include Concerns::CameraInteractionMethod::PreviewOnly

  def preview_url
    "http://#{host}/videostream.cgi?user=#{username}&pwd=#{password}"
  end

  def preview_needs_refreshing?
    false
  end
end
