class Api
  class FreeBusy

    def self.is_free_now?(rooms)
      is_free_between?(rooms, Time.current, Event::CURRENT.from_now)
    end

    def self.is_free_between?(rooms, from_time, to_time)
      new(rooms).is_free_between?(from_time, to_time)
    end

    def self.all_free_slots(rooms, date)
      new(rooms).all_free_slots(date)
    end

    attr_reader :rooms

    def initialize(rooms)
      @rooms = Array(rooms).flatten
    end

    def is_free_between?(from_time, to_time)
      result = execute_for(from_time, to_time)

      result = Hash[*result.map {|id, hash| [id, hash['busy'].empty?]}.flatten]
      map_the_calendar_name!(result)
    end

    def all_free_slots(date)
      start_time = if date > Date.current
        Time.zone.local(date.year, date.month, date.day, 9)
      else
        1.minutes.from_now
      end

      end_time = Time.zone.local(date.year, date.month, date.day, 17)
      result = execute_for(start_time, end_time)

      result = result.map do |id, hash|
        busy_hashes = hash['busy'].sort_by{|busy_slot| Time.zone.parse(busy_slot['start'])}
        [id, convert_busy_to_free(busy_hashes, start_time, end_time)]
      end

      result = result.reject{|_, free_hashes| free_hashes.empty?}
    end

    private

    def execute_for(from_time, to_time)
      Api.execute(query(from_time, to_time)).data.calendars.to_hash
    end

    def map_the_calendar_name!(hash)
      hash = hash.map do |key, hash|
        [Room.find_by_id(key), hash]
      end
      Hash[*hash.flatten]
    end

    def query(from_time, to_time)
      {
        api_method: Api.calendar_api.freebusy.query,
        body_object: {
          timeMin: from_time.utc.iso8601,
          timeMax: to_time.utc.iso8601,
          items: rooms.map{ |room| {id: room.id} }
        }
      }
    end

    def convert_busy_to_free(hashes, start_time, end_time)
      free_hashes = []
      last_end_time = start_time

      hashes.each do |busy_hash|
        current_busy_start_time = Time.zone.parse(busy_hash['start'])
        current_busy_end_time   = Time.zone.parse(busy_hash['end'])

        if current_busy_start_time > last_end_time
          free_hash            = {}
          free_hash[:start]    = last_end_time
          free_hash[:end]      = current_busy_start_time
          free_hash[:duration] = current_busy_start_time - last_end_time
          binding.pry if free_hash.nil?
          free_hashes << free_hash
        end

        last_end_time = current_busy_end_time
      end

      if end_time > last_end_time
        free_hash            = {}
        free_hash[:start]    = last_end_time
        free_hash[:end]      = end_time
        free_hash[:duration] = end_time - last_end_time
        free_hashes << free_hash
      end

      free_hashes
    end

  end
end
