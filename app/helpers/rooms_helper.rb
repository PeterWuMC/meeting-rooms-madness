module RoomsHelper

  def find_room(name)
    @rooms.detect { |room, _| room.name == name.to_s.downcase }
  end

  def call_td(room_free)
    if room_free
      'free_td'
    else
      'busy_td'
    end
  end

  def current_event_summary(room)
    event = current_event(room)

    if event.nil?
      'Cannot find event'
    elsif event.summary.present?
      event.summary
    elsif event.description.present?
      event.description
    else
      event.creator['email']
    end
  end

  def current_event_end_time(room)
    event = current_event(room)
    return 'Cannot find event' if event.nil?

    end_time = event.end_time
    if end_time > Time.new(Time.current.year, Time.current.month, Time.current.day, 17, 0, 0, '+00:00')
      'end of the day'
    else
      event.end_time.strftime('%H:%M')
    end
  end

  private

  def current_event(room)
    event = Event.all_of_today(room).detect { |event| event.current? }
  end

end
