require 'yaml'

class Room
  ALL = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', 'config', 'meeting_rooms.yml'))

  def self.all
    ALL.map{|id, name| new(id: id)}
  end

  def self.find_by_name(name)
    new(name: name)
  end

  def self.find_by_id(id)
    new(id: id)
  end

  def self.is_free_now?
    Api::FreeBusy.is_free_now?(all)
  end

  def self.current_free_rooms
    Api::FreeBusy.is_free_now?(all).select { |_, free| free }
  end

  attr_reader :id

  def initialize(opts)
    @id   = opts.delete(:id)
    name = opts.delete(:name)

    if name
      name = name.downcase.to_s
      @id, @attr = ALL.detect{|_, room_attr| room_attr['name'] == name}
    elsif @id
      @attr = ALL[@id]
    end

    if @id.blank? || @attr.blank?
      raise 'Bad!'
    end
  end

  def name
    @attr['name']
  end

  def has_projector?
    @attr['projector']
  end

  def max_occupants
    @attr['max_occupants']
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
