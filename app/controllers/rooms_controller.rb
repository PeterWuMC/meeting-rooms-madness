class RoomsController < ApplicationController

	def index
	  @rooms = Room.is_free_now?

	end


end
