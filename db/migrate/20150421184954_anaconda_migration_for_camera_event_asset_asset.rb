class AnacondaMigrationForCameraEventAssetAsset < ActiveRecord::Migration
  def change
    add_column :camera_event_assets, :asset_filename, :string
    add_column :camera_event_assets, :asset_file_path, :text
    add_column :camera_event_assets, :asset_size, :integer
    add_column :camera_event_assets, :asset_original_filename, :text
    add_column :camera_event_assets, :asset_stored_privately, :boolean
    add_column :camera_event_assets, :asset_type, :string
  end
end
