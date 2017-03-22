class AddPositionToCameras < ActiveRecord::Migration
  def change
    add_column :cameras, :position, :integer, index: true
    Camera.order(:id).each.with_index(1) do |camera, index|
      camera.update_column :position, index
    end
  end
end
