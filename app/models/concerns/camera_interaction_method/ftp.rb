module Concerns::CameraInteractionMethod::Ftp
  extend ActiveSupport::Concern

  def default_ftp_port
    21
  end

  def ftp_host_with_default
    ftp_host.presence || host
  end

  def ftp_port_with_default
    ftp_port.presence || default_ftp_port
  end

  def ftp_username_with_default
    ftp_username.presence || username
  end

  def ftp_password_with_default
    ftp_password.presence || password
  end

  def ftp_path_with_default
    ftp_path.presence || '/'
  end

  def ftp
    return @ftp if @ftp
    @ftp = Net::FTP.new
    @ftp.passive = false
    @ftp.connect(ftp_host_with_default, ftp_port_with_default)  # here you can pass a non-standard port number
    @ftp.login(ftp_username_with_default, ftp_password_with_default)
    @ftp.chdir(ftp_path_with_default)
    return @ftp
  end

  def ftp_reset_working_directory!
    ftp.chdir(ftp_path_with_default)
  end

  def all_ftp_files(file_limit: 999_999)
    files = list_directory(ftp_path_with_default, recursive: true, return_type: :files, max_file_count: file_limit)
    return files
  end

  def delete_empty_ftp_directories_recursively!(starting_directory = ftp_path_with_default)
    count = 0
    objects = list_directory(starting_directory, return_type: :hash)
    if objects[:files].empty? && objects[:directories].empty?
      Rails.logger.debug "#{starting_directory} is empty. Deleting"
      count += 1
      ftp.rmdir(starting_directory) unless SystemSetting.read_only_mode
    else
      objects[:directories].each do |directory|
        delete_empty_ftp_directories_recursively!(directory)
      end
    end
    return count
  end

  def with_ensure_ftp_close(&block)
    begin
      yield
    ensure
      ftp.close
    end
  end

  def process_camera_event(camera_event)
    tempfile = create_tempfile("camera-#{id.to_s}-")
    file = camera_event.remote_id

    Rails.logger.debug "Fetching file from FTP: #{file}"
    ftp.getbinaryfile(file, tempfile.path)

    camera_event.event_timestamp = timestamp_from_file(file: file)

    create_camera_event_assets(camera_event: camera_event, input: tempfile.path)

    Rails.logger.debug "Camera Event Complete!"
    camera_event.complete!

    if SystemSetting.read_only_mode
      Rails.logger.debug "READ ONLY MODE. Skipping delete for #{file} from FTP server"
    else
      Rails.logger.debug "Deleting #{file} from FTP server"
      ftp.delete(file)
    end
  rescue Net::FTPPermError => ex
    Rails.logger.debug "Net::FTPPermError: #{ex.inspect}"
    return if ex.message.include?("No such file or directory")
  ensure
    ftp.close

    Rails.logger.debug "Deleting tempfile"
    tempfile.close
    tempfile.unlink
    File.delete(tempfile.path) if tempfile.path && File.exist?(tempfile.path)
    tempfile = nil # Grasping at straws
  end

  private

  def set_camera_event_timestamp(file:)
    raise NotImplementedError, "You must implement `set_camera_event_timestamp` in your subclass."
  end

  def list_directory(directory, return_type: :files, recursive: false, current_file_count: 0, max_file_count: 999_999)
    Rails.logger.debug "Current dir: #{ftp.pwd}" rescue nil
    Rails.logger.debug "Changing into directory: #{directory}"
    ftp.chdir(directory)

    begin
      current_dir = ftp.pwd
    rescue Net::FTPReplyError => e
      # Sometimes this errors when it's actually successful
      raise e unless e.message.include?("command successful")
    end

    begin
      list = ftp.list
    rescue Errno::ECONNRESET, Errno::ENOTCONN
      # Since were likely deep in the folds here, let's just ignore this
      # failure so we can return the files we already found up the recursive stream
      list = []
    end

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

    directories = directories.collect{|f| "#{current_dir}/#{f}"}
    files       = files.collect{|f| "#{current_dir}/#{f}"}

    if recursive
      directories.each do |directory|
        Rails.logger.debug "Going to list files in #{directory}"
        objects = list_directory(directory, recursive: true, return_type: :hash, current_file_count: current_file_count, max_file_count: max_file_count)
        files += objects[:files]
        directories += objects[:directories]

        current_file_count += files.size
        break if current_file_count >= max_file_count
      end
    end

    Rails.logger.debug "Files count: #{files.size}"
    Rails.logger.debug "directories count: #{directories.size}"

    case return_type
      when :files       then return files
      when :directories then return directories
      when :hash        then return { files: files, directories: directories }
      else raise "invalid return_array value"
    end

  end


end
