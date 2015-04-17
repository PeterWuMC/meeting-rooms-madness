class RoomsController < ApplicationController

  def index
    @rooms = Room.all_free_now?
  end

  def find
    @rooms = AvailableRoomService.find_next_available_room_for(params[:date].to_date, params[:duration].to_i)
  end
end
