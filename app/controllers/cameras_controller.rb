class CamerasController < ApplicationController
  skip_before_action :authenticate_user!, only: [:live, :preview]
  before_action :ensure_valid_key,        only: [:live, :preview]
  before_action :load_camera,             only: [:show, :preview]

  def index
    @cameras = Camera.ordered
    @cameras = @cameras.active unless params[:inactive] == "1"
  end

  def live
    @cameras = Camera.active.ordered
  end

  def show
    @events = @camera.camera_events.displayable.ordered.page(params[:page]).per(24)
  end

  def preview
    redirect_to camera_path(@camera) unless @camera.preview_requires_basic_auth?
    send_data open(@camera.preview_url, http_basic_authentication: [@camera.username, @camera.password]).read,
      disposition: 'inline',
      type: 'image/jpeg'
  end

  private
  def load_camera
    @camera = Camera.find(params[:id])
  end

  def ensure_valid_key
    authenticate_user! unless has_valid_key?
  end
end
