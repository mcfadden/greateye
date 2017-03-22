class Camera::Foscam::Sd < Camera::Foscam


  def preview_url
    "http://#{host}/videostream.cgi?user=#{username}&pwd=#{password}"
  end
end
