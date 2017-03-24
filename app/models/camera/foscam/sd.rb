class Camera::Foscam::Sd < Camera::Foscam


  def preview_url
    "http://#{host}/videostream.cgi?user=#{username}&pwd=#{password}"
  end

  def perform_remote_cleanup!
    false
  end
end
