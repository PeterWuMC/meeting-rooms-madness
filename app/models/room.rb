require 'yaml'

class Room
  ALL = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'config', 'meeting_rooms.yml'))

  def self.all
    @all ||= begin
      ALL.map do |id, attrs|
        new(id, attrs)
      end
    end
  end

  def self.find_by_name(name)
    all.detect { |room| room.name == name.downcase.to_s }
  end

  def self.find_by_id(id)
    all.detect { |room| room.id == id }
  end

  def self.all_free_now?
    Api::FreeBusy.is_free_now?(all)
  end

  def self.current_free_rooms
    Api::FreeBusy.is_free_now?(all).select { |_, free| free }.keys
  end

  def self.free_rooms_between(from_time, to_time)
    Api::FreeBusy.is_free_between?(all, from_time, to_time).select { |_, free| free }.keys
  end

  attr_reader :id

  def initialize(id, attrs)
    @id    = id
    @attrs = attrs
  end

  def name
    @attrs['name']
  end

  def has_projector?
    @attrs['projector']
  end

  def max_occupants
    @attrs['max_occupants']
  end

  def is_free_now?
    result = Api::FreeBusy.is_free_now?(self)
    result.detect{|room, _| self.id == room.id}.last
  end

  def is_free_between?(from_time, to_time)
    result = Api::FreeBusy.is_free_between?(self, from_time, to_time)
    result.detect{|room, _| self.id == room.id}.last
  end

  def inspect
    "#<Room: #name='#{name}' #id='#{id}'>"
  end
end
