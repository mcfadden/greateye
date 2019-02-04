require 'uri'
require 'net/http'
require 'net/http/digest_auth'
class CamerasController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update_live_focus]
  skip_before_action :authenticate_user!, only: [:live, :live_focus, :update_live_focus, :preview]
  before_action :ensure_valid_key,        only: [:live, :live_focus, :update_live_focus, :preview]
  before_action :load_camera,             only: [:show, :preview]

  def index
    @cameras = Camera.ordered
    @cameras = @cameras.active unless params[:inactive] == "1"
  end

  def live
    if live_focus_camera_id.to_i > 0
      @cameras = Camera.where(id: live_focus_camera_id)
    else
      @cameras = Camera.active.ordered
    end
  end

  def live_focus
    render json: { camera_id: live_focus_camera_id || 0 }
  end

  def update_live_focus
    focus_for = params[:focus_for] || 1.hour
    Sidekiq.redis { |r| r.setex("live_focus_camera_id", focus_for.to_i, params[:camera_id]) }
    render text: 'ok'
  end

  def show
    @events = @camera.camera_events.displayable.includes(:primary_thumbnail, :primary_video).ordered.page(params[:page]).per(24)
  end

  def preview
    redirect_to camera_path(@camera) unless @camera.preview_requires_basic_auth? || @camera.preview_requires_digest_auth?
    send_data camera_data,
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

  def camera_data
    if @camera.preview_requires_basic_auth?
      open(@camera.preview_url, http_basic_authentication: [@camera.username, @camera.password]).read
    elsif @camera.preview_requires_digest_auth?
      digest_auth = Net::HTTP::DigestAuth.new
      uri = URI.parse @camera.preview_url
      uri.user = @camera.username
      uri.password = @camera.password

      http = Net::HTTP.new uri.host, uri.port
      request = Net::HTTP::Get.new uri.request_uri

      response = http.request request
      # response is a 401 response with a WWW-Authenticate header

      auth = digest_auth.auth_header uri, response['www-authenticate'], 'GET'

      # create a new request with the Authorization header
      request = Net::HTTP::Get.new uri.request_uri
      request.add_field 'Authorization', auth

      # re-issue request with Authorization
      response = http.request request
      response.body
    else
      raise "invalid preview auth type"
    end
  end

  def live_focus_camera_id
    @live_focus_camera_id = Sidekiq.redis{ |r| r.get("live_focus_camera_id") }
  end
end
