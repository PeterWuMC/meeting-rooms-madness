require 'yaml'

class Meetopia
  class FreeBusy

    def self.is_free_now?(rooms)
      is_free_between?(rooms, Time.now, Time.now + 3600)
    end

    def self.is_free_between?(rooms, from_time, to_time)
      new.is_free_between?(rooms, from_time, to_time)
    end

    def initialize; end

    def is_free_between?(rooms, from_time, to_time)
      rooms = Array(rooms).flatten
      query = {
        api_method: Meetopia.calendar_api.freebusy.query,
        body_object: {
          timeMin: from_time.utc.iso8601,
          timeMax: to_time.utc.iso8601,
          items: rooms.map{ |room| {id: room.id} }
        }
      }
      result = Meetopia.client.execute!(query).data.calendars.to_hash

      result = Hash[*result.map {|id, busy_hash| [id, busy_hash['busy'].empty?]}.flatten]

      map_the_calendar_name!(result)
    end

    private

    def map_the_calendar_name!(hash)
      hash = hash.map do |key, hash|
        [Room[key], hash]
      end
      Hash[*hash.flatten]
    end
  end
end
