class CamerasController < ApplicationController
  skip_before_action :authenticate_user!, only: [:live]

  def index
    if params[:inactive] == "1"
      @cameras = Camera.all
    else
      @cameras = Camera.active
    end
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
