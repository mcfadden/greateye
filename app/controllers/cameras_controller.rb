class CamerasController < ApplicationController
  skip_before_action :authenticate_user!, only: [:live]

  def index
    @cameras = Camera.ordered
    @cameras = @cameras.active unless params[:inactive] == "1"
  end

  def live
    authenticate_user! unless has_valid_key?
    @cameras = Camera.active.ordered
  end

  def show
    @camera = Camera.find(params[:id])
    @events = @camera.camera_events.complete.ordered.page(params[:page]).per(24)
  end
end
