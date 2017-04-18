class Admin::CamerasController < Admin::BaseController
  before_action :load_camera, except: [:index, :create, :new]

  def index
    @cameras = Camera.ordered
  end

  def new
    @camera = Camera.new
  end

  def move_higher
    @camera.move_higher
    redirect_to admin_cameras_path
  end

  def move_lower
    @camera.move_lower
    redirect_to admin_cameras_path
  end

  def show
    # TODO: Make this page
    redirect_to admin_cameras_path
  end

  def create
    @camera = Camera.create(camera_params)
    redirect_to admin_camera_path @camera
  end

  def update
    if @camera.update(camera_params)
      flash[:notice] = "Updated #{@camera.name}"
      redirect_to admin_camera_path @camera
    else
      flash[:error] = "Error while updating #{@camera.name}: #{@camera.errors.full_messages}"
      render :edit
    end
  end

  def edit
  end

  def destroy
    @camera.destroy
    redirect_to cameras_path
  end

  private
  def load_camera
    @camera = Camera.find(params[:id])
  end

  def camera_params
    params.require(:camera).permit(
      :name,
      :active,
      :camera_type,
      :username,
      :password,
      :host,
      :thumbnail_count,
      :thumbnail_start_seconds,
      :thumbnail_interval_seconds,
      :ftp_username,
      :ftp_password,
      :ftp_host,
      :ftp_port,
      :ftp_path
    )
  end
end
