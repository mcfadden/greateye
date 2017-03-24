class AddRemoteIdToCameraEvent < ActiveRecord::Migration
  def change
    add_column :camera_events, :remote_id, :text
    add_index :camera_events, :remote_id, unique: true
  end
end
