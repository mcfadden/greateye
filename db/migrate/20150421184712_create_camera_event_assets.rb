class CreateCameraEventAssets < ActiveRecord::Migration
  def change
    create_table :camera_event_assets do |t|
      t.references :camera_event, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
