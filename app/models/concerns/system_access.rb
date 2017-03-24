module SystemAccess
  extend ActiveSupport::Concern

  TEMPFILE_DIRECTORY = Rails.root.join('tmp').join('camera-event-assets')

  included do
    # Ensure the tempfile directory is setup
    FileUtils::mkdir_p(TEMPFILE_DIRECTORY)
  end

  def create_tempfile(prefix)
    return Tempfile.new(prefix, TEMPFILE_DIRECTORY )
  end

  def run_shell_command( cmd, desc = "", raise_error_on_fail = true )
    #puts cmd
    output = `#{cmd} 2>&1`
    status = $?.exitstatus

    #puts "Output:\n#{output}"
    #puts "Status:\n#{status}"

    raise "#{desc} failed. #{output}" if status != 0 && raise_error_on_fail
    return output
  end
end
