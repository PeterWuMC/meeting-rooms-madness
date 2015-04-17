class AvailableRoomService

  def self.find_room_between(from_time, to_time)
    new(from_time, to_time).find
  end

  def self.find_room_with_projector_between(from_time, to_time)
    new(from_time, to_time, projector: true).find
  end

  def self.find_next_available_room_for(date, duration)
    rooms = Api::FreeBusy.all_free_slots(Room.all, date)

    rooms = rooms.select do |room_id, free_hashes|
      free_hashes.any?{|free_hash| free_hash[:duration] >= duration}
    end

    rooms = rooms.map do |room_id, free_hashes|
      room = Room.find_by_id(room_id)
      eligible_slot = free_hashes.detect{|free_hash| free_hash[:duration] >= duration}
      start_time = eligible_slot[:start]
      end_time   = start_time + duration

      [room, {start: start_time, end: end_time}]
    end
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
