class EventsController < ApplicationController

  def create
    room      = Room.find_by_name(params[:room_id])
    duration  = params[:duration].to_i
    from_time = Time.parse(params[:from_time])
    to_time   = from_time + duration

    flash[:notice] = "Event is created for #{room.name.humanize} room"
    redirect_to rooms_path
  end

end
