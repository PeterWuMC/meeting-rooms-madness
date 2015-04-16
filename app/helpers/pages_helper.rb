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
		event = Event.all_of_today(room).detect do |event|
					event.current?
				end
		return  if event.nil?

		if !event.summary.present?

			event.creator['email']
		else
			event.summary
				
		end
	end

	def current_event_end_time(room)
		event = Event.all_of_today(room).detect do |event|
					event.current?
				end
		return  if event.nil?


	  event.end_time.strftime('%H:%M')
				
	end
end
