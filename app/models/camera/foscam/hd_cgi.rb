class Camera::Foscam::HdCgi < Camera::Foscam

  def video_events?
    true
  end

  def default_ftp_port
    50021
  end

  def preview_url
    "http://#{host}/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=#{username}&pwd=#{password}"
  end

end
