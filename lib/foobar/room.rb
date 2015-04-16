require 'yaml'

class Foobar
  class Room
    ALL = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'config', 'meeting_rooms.yml'))

    def self.all
      ALL.map{|id, name| new(id: id)}
    end

    def self.[](id)
      new(id: id)
    end

    def self.find_by_name(name)
      new(name: name)
    end

    def self.is_free_now?
      FreeBusy.is_free_now?(all)
    end

    attr_reader :name, :id

    def initialize(opts)
      @id   = opts.delete(:id)
      @name = opts.delete(:name)

      if @name
        @id = ALL.key(@name.downcase.to_s)
      elsif @id
        @name = ALL[@id]
      else
        raise 'FOOBAR'
      end
    end

    def is_free_now?
      result = FreeBusy.is_free_now?(self)
      result.detect{|room, _| self.id == room.id}.last
    end

    def is_free_between?(from_time, to_time)
      result = FreeBusy.is_free_between?(self, from_time, to_time)
      result.detect{|room, _| self.id == room.id}.last
    end

  end
end
