class AddStatusToCameraEvent < ActiveRecord::Migration
  def change
    add_column :camera_events, :status, :integer, default: 0
    add_index :camera_events, :status
  end
end
