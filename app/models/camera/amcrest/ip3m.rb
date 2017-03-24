class Camera::Amcrest::Ip3m < Camera::Amcrest

  def preview_url
    "http://#{username}:#{password}@#{host}/cgi-bin/realmonitor.cgi?action=getStream&channel=1&subtype=0"
  end

  def perform_remote_cleanup!
    delete_empty_ftp_directories_recursively!
  end



end
