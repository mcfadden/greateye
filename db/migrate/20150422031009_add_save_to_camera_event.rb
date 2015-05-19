class AddSaveToCameraEvent < ActiveRecord::Migration
  def change
    add_column :camera_events, :keep, :boolean, default: false
    add_index :camera_events, :keep
  end
end
