class CameraEventsController < ApplicationController
  def index
    @events = CameraEvent.complete.ordered.page(params[:page]).per(24)
  end
  
  def kept
    @events = CameraEvent.complete.kept.ordered.page(params[:page]).per(24)
  end
  
  def keep
    @event = CameraEvent.find(params[:id])
    @event.keep!
    redirect_to :back
  end
  
  def unkeep
    @event = CameraEvent.find(params[:id])
    @event.unkeep!
    redirect_to :back
  end
end
