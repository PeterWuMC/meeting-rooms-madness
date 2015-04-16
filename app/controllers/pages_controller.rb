class PagesController < ApplicationController

	def index
	  @rooms = Room.is_free_now?
	  		
	end


end
