class CamerasController < ApplicationController
  def index
    @cameras = Camera.all
  end
  
  def show
    @camera = Camera.find(params[:id])
    @events = @camera.camera_events.complete.ordered.page(params[:page]).per(24)
  end
end
