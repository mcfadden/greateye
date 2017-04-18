class AddThumbnailSettingsToCameras < ActiveRecord::Migration
  def change
    add_column :cameras, :thumbnail_count, :integer, default: 1
    add_column :cameras, :thumbnail_start_seconds, :integer, default: 5
    add_column :cameras, :thumbnail_interval_seconds, :integer, default: 1
  end
end
