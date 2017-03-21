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
      CameraEvent.order(:camera_id).includes(:camera).where("event_timestamp > ?", 70.days.ago).each do |ce|
        next if ce.duration > 1.hour
        @camera_event_timeline << [ce.camera.name, ce.event_timestamp + 7.hours, ce.event_timestamp + ce.duration + 7.hours]
      end
    end

    @events = CameraEvent.complete.ordered.page(params[:page]).per(24)
  end

  def selected_from_timeline
     @camera = Camera.find_by( name: params[:camera] )
     time = DateTime.parse(params[:occurred_at]).utc - 7.hours
     @event = @camera.camera_events.where( event_timestamp: (time - 1.second)..(time + 1.second)  ).first

     redirect_to camera_events_path(show_event_id: @event&.id)
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
