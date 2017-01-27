class CameraEventsController < ApplicationController
  def index
    if params[:show_event_id]
      event = CameraEvent.find(params[:show_event_id])
      offset = CameraEvent.complete.ordered.where("event_timestamp > ?", event.event_timestamp).count
      page = (offset / 24) + 1
      params[:page] = page
    end

    if params[:page].nil? || params[:page] == 1
      @camera_event_timeline = []
      CameraEvent.includes(:camera).where("event_timestamp > ?", 24.hours.ago).each do |ce|
        next if ce.duration > 1.hour
        @camera_event_timeline << [ce.camera.name, ce.event_timestamp, ce.event_timestamp + ce.duration]
      end
    end

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
