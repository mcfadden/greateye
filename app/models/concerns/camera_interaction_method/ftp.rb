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

  def all_ftp_files
    files = list_directory(ftp_path_with_default, recursive: true, return_type: :files)
    return files
  end

  def delete_empty_ftp_directories_recursively!(starting_directory = ftp_path_with_default)
    count = 0
    objects = list_directory(starting_directory, return_type: :hash)
    if objects[:files].empty? && objects[:directories].empty?
      Rails.logger.debug "#{starting_directory} is empty. Deleting"
      count += 1
      ftp.rmdir(starting_directory) unless READ_ONLY_MODE
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

  private

  def list_directory(directory, return_type: :files, recursive: false)
    Rails.logger.debug "Current dir: #{ftp.pwd}"
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

    directories = directories.collect{|f| "#{current_dir}/#{f}"}
    files       = files.collect{|f| "#{current_dir}/#{f}"}

    if recursive
      directories.each do |directory|
        Rails.logger.debug "Going to list files in #{directory}"
        objects = list_directory(directory, recursive: true, return_type: :hash)
        files += objects[:files]
        directories += objects[:directories]
      end
    end

    case return_type
      when :files       then return files
      when :directories then return directories
      when :hash        then return { files: files, directories: directories }
      else raise "invalid return_array value"
    end

  end


end
