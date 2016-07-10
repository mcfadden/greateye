class CamerasController < ApplicationController
  skip_before_action :authenticate_user!, only: [:live]
  
  def index
    @cameras = Camera.with_recordings.all
  end
  
  def live
    authenticate_user! unless has_valid_key?
    @cameras = Camera.all
  end
  
  def show
    @camera = Camera.find(params[:id])
    @events = @camera.camera_events.complete.ordered.page(params[:page]).per(24)
  end
end
