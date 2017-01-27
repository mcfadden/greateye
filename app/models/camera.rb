require "net/ftp"
class Camera < ActiveRecord::Base
  has_many :camera_events

  enum model: {
    fi9821wv2: 0,
    fi8910w: 1,
  }

  scope :with_recordings, ->{ fi9821wv2 }

  def find_and_process_new_motion_events
    FindFtpMotionEventsWorker.perform_async(id) if can_record_events?
  end

  def can_record_events?
    fi9821wv2?
  end

  def connect_to_ftp
    ftp = Net::FTP.new
    ftp.passive = false
    ftp.connect(host, port)  # here you can pass a non-standard port number
    ftp.login(username, password)
    return ftp
  end

  def files_via_ftp(ftp)
    ftp ||= connect_to_ftp
    files = files_in_directory(ftp, ftp.pwd, true)
    return files
  end

  def delete_empty_directories(ftp: nil)
    ftp ||= connect_to_ftp
    files_in_directory(ftp, ftp.pwd, true, delete_empty_directories: true)
  end

  def port
    case model
    when "fi9821wv2"
      50021
    else
      nil
    end
  end

  def preview_url
    case model.to_sym
    when :fi9821wv2
      "http://#{host}/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=#{username}&pwd=#{password}"
    when :fi8910w
      #"http://#{host}:#{port}/snapshot.cgi?user=#{username}&pwd=#{password}")
      "http://#{host}/videostream.cgi?user=#{username}&pwd=#{password}"
    else
      return false
    end
  end

  private

  def files_in_directory(ftp, directory, recursive, delete_empty_directories: false)
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

    if delete_empty_directories && files.empty? && directories.empty?
      Rails.logger.debug "#{directory} appears to be empty. Deleting"
      ftp.rmdir(directory) unless READ_ONLY_MODE
    end

    if recursive
      directories.each do |dir|
        Rails.logger.debug "Going to list files in #{current_dir}/#{dir}"
        files += files_in_directory(ftp, "#{current_dir}/#{dir}", recursive, delete_empty_directories: delete_empty_directories)
      end
    end
    return files
  end

end
