require "net/ftp"
class Camera < ActiveRecord::Base
  has_many :camera_events
  
  enum model: {
    fi9821wv2: 0,
    fi8910w: 1,
  }
  
  def find_and_process_new_motion_events
    FindFtpMotionEventsWorker.perform_async(id)
  end
  
  def connect_to_ftp
    ftp = Net::FTP.new
    ftp.connect(host, port)  # here you can pass a non-standard port number
    ftp.login(username, password)
    return ftp
  end
  
  def files_via_ftp(ftp)
    ftp ||= connect_to_ftp
    files = files_in_directory(ftp, ftp.pwd, recursive = true)
    return files
  end
  
  def port
    case model
    when "fi9821wv2"
      50021
    else
      nil
    end
  end

  private
  
  def files_in_directory(ftp, directory, recursive)
    current_dir = ftp.pwd
    Rails.logger.debug "Current dir: #{current_dir}"
    
    Rails.logger.debug "Changing into directory: #{directory}"
    ftp.chdir(directory)
    
    current_dir = ftp.pwd

    list = ftp.list
    
    directories = []
    files = []
    
    list.each do |item|
      item = item.split(" ")
      if item.first.starts_with?("d")
        directories << item.last
      elsif item.first.starts_with?("-")
        files << item.last
      end
    end

    Rails.logger.debug directories
  
    files = files.collect{|f| "#{current_dir}/#{f}"}

    if recursive
      directories.each do |dir|
        Rails.logger.debug "Going to list files in #{current_dir}/#{dir}"
        files += files_in_directory(ftp, "#{current_dir}/#{dir}", recursive)
      end
    end
    return files
  end
  
end
