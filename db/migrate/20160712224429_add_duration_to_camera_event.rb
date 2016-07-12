class AddDurationToCameraEvent < ActiveRecord::Migration
  def change
    add_column :camera_events, :duration, :integer
  end
end
