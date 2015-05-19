class CreateCameraEvents < ActiveRecord::Migration
  def change
    create_table :camera_events do |t|
      t.references :camera, index: true, foreign_key: true
      t.integer :event_type, default: 0
      t.datetime :event_timestamp

      t.timestamps null: false
    end
  end
end
