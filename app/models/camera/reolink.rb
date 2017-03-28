class Camera::Reolink < Camera
  include Concerns::CameraInteractionMethod::Ftp

  def video_events?
    true
  end

  def preview_url
    "http://#{host}/cgi-bin/api.cgi?cmd=Snap&channel=0&rs=abc#{rand(12)}&user=#{username}&password=#{password}"
  end

end
