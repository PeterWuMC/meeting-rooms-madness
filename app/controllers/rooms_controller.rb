class RoomsController < ApplicationController

  def index
    @rooms = Room.all_free_now?
  end


end
