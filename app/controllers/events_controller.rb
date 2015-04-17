class EventsController < ApplicationController

  def create
    @room = Room.find_by_name(params[:room_id])
    if params[:plan] == 'adhoc'
      duration  = params[:duration].to_i
      @from_time = Time.current
      @to_time   = @from_time + duration
    else
      @from_time = Time.zone.parse(params[:from_time])
      @to_time   = Time.zone.parse(params[:to_time])
    end

    event = Event.create(@room, @from_time, @to_time, 'Adhoc meeting')
    flash[:notice] = "We have booked '#{@room.name.humanize}' for you until #{event.end_time.to_formatted_s(:short)}"
    redirect_to rooms_path
  end

end
