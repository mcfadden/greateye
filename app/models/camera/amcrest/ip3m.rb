class Camera::Amcrest::Ip3m < Camera::Amcrest

  def preview_url
    "http://#{username}:#{password}@#{host}/cgi-bin/realmonitor.cgi?action=getStream&channel=1&subtype=0"
  end

end
