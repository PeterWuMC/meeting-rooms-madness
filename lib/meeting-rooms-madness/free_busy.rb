require 'yaml'

class MeetingRoomMadness
  class FreeBusy

    def self.is_free_now?
      is_free_at?(Time.now, Time.now + 3600)
    end

    def self.is_free_at?(from_time, to_time)
      new.is_free_at?(from_time, to_time)
    end

    def initialize; end

    def is_free_at?(from_time, to_time)
      query = {
        api_method: MeetingRoomMadness.calendar_api.freebusy.query,
        body_object: {
          timeMin: from_time.utc.iso8601,
          timeMax: to_time.utc.iso8601,
          items: Rooms.keys.map{|room| {id: room} }
        }
      }
      result = MeetingRoomMadness.client.execute!(query)

      map_the_calendar_name!(result.data.calendars.to_hash)
    end

    private

    def map_the_calendar_name!(hash)
      hash = deep_clone(hash)
      hash = hash.map do |key, hash|
        [Rooms[key], hash]
      end
      Hash[*hash]
    end

    def deep_clone(hash)
      Marshal.load(Marshal.dump(hash))
    end
  end
end
