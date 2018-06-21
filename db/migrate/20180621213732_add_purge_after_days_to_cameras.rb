class AddPurgeAfterDaysToCameras < ActiveRecord::Migration
  def change
    add_column :cameras, :purge_after_days, :integer, default: 30
  end
end
