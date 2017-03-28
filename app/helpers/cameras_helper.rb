module CamerasHelper
  def make_and_models_collection_for_select(camera)
    grouped_options_for_select(
      Camera.makes.map do |make|
        [make, Camera.models_for(make: make).map{|model| [model, "#{make}:::#{model}"]}]
      end.to_h,
      camera.camera_type
    )
  end

  def preview_url(camera:)
    if camera.preview_requires_basic_auth?
      preview_camera_url(camera)
    else
      camera.preview_url
    end
  end
end
