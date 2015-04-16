module PagesHelper

	def call_status_class(room_free)
		if room_free
			'free'
		else
			'busy'
		end
	end

end
