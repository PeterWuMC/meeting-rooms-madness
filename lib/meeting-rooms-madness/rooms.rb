require 'yaml'

class MeetingRoomMadness
  class Rooms
    ALL = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'config', 'meeting_rooms.yml'))

    def self.all
      ALL
    end

    def self.[](key)
      ALL[key]
    end

    def self.keys
      ALL.keys
    end
  end
end
