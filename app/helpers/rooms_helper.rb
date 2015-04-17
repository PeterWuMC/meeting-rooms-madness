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

    if end_time > Time.zone.local(Time.current.year, Time.current.month, Time.current.day, 17)
      'end of the day'
    else
      l(event.end_time, format: :time_only)
    end
  end

  def find_room_dates_array(number_of_entries)
    array = []
    date  = Date.today

    number_of_entries.times.each do
      while date.saturday? || date.sunday?
        date = date.tomorrow
      end
      array += [[find_room_dates_display_value(date) , date]]
      date = date.tomorrow
    end

    array
  end

  def find_room_duration_array
    [
      ['30 minutes', 30.minutes],
      ['1 hour',     1.hour],
    ]
  end


  private

  def current_event(room)
    event = Event.all_of_today(room).detect { |event| event.current? }
  end

  def find_room_dates_display_value(date)
    if date.today?
      'Today'
    elsif date == Date.tomorrow
      'Tomorrow'
    else
      date.strftime('%A')
    end
  end

end
