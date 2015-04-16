class Api
  class FreeBusy

    def self.is_free_now?(rooms)
      is_free_between?(rooms, Time.current, Time.current + 1.hour)
    end

    def self.is_free_between?(rooms, from_time, to_time)
      new(rooms).is_free_between?(from_time, to_time)
    end

    attr_reader :rooms

    def initialize(rooms)
      @rooms = Array(rooms).flatten
    end

    def is_free_between?(from_time, to_time)
      query = {
        api_method: api_method,
        body_object: {
          timeMin: from_time.utc.iso8601,
          timeMax: to_time.utc.iso8601,
          items: rooms.map{ |room| {id: room.id} }
        }
      }
      result = Api.client.execute!(query).data.calendars.to_hash

      result = Hash[*result.map {|id, busy_hash| [id, busy_hash['busy'].empty?]}.flatten]

      map_the_calendar_name!(result)
    end

    private

    def map_the_calendar_name!(hash)
      hash = hash.map do |key, hash|
        [Room.find_by_id(key), hash]
      end
      Hash[*hash.flatten]
    end

    def api_method
      Api.calendar_api.freebusy.query
    end

  end
end
