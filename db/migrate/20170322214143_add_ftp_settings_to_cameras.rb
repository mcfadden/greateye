class AddFtpSettingsToCameras < ActiveRecord::Migration
  def change
    add_column :cameras, :ftp_host, :string
    add_column :cameras, :ftp_port, :string, default: 21
    add_column :cameras, :ftp_username, :string
    add_column :cameras, :ftp_password, :string
    add_column :cameras, :ftp_path, :string
  end
end
