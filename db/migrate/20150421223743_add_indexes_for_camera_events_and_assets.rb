class AddIndexesForCameraEventsAndAssets < ActiveRecord::Migration
  def change
    add_index :camera_events, :event_timestamp
    add_index :camera_event_assets, :asset_type
  end
end
