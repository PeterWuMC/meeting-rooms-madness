class AvailableRoomService

  def self.find_room_between(from_time, to_time)
    new(from_time, to_time).find
  end

  def self.find_room_with_projector_between(from_time, to_time)
    new(from_time, to_time, projector: true).find
  end

  def initialize(from_time, to_time, additional_requirements={})
    @from_time = from_time
    @to_time   = to_time
    @projector = additional_requirements[:projector]
  end

  def find
    rooms = Room.free_rooms_between(@from_time, @to_time)
    if @projector
      rooms.select! {|room| room.has_projector? }
    end

    rooms
  end

end
