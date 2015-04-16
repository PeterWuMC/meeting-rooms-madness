module PagesHelper

	def call_status_class(room_free)
		if room_free
			'free'
		else
			'busy'
		end
	end

	def call_square(room_free)
		if room_free
			'free_square'
		else
			'busy_square'
		end
	end

	def current_event(room)
		Event.all_of_today(room).detect do |event|
			event.current?
		end
	end

end
