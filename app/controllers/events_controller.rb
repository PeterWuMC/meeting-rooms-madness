class EventsController < ApplicationController

  def create
    room      = Room.find_by_name(params[:room_id])
    duration  = params[:duration].to_i
    from_time = Time.parse(params[:from_time])
    to_time   = from_time + duration

    Event.create(room, from_time, to_time, 'Adhoc meeting')
    flash[:notice] = "We have booked '#{room.name.humanize}' for you until #{to_time}"
    redirect_to rooms_path
  end

end
