class AddStatusToCameraEventAssets < ActiveRecord::Migration
  def change
    add_column :camera_event_assets, :status, :integer, default: 0
    add_index :camera_event_assets, :status
  end
end
