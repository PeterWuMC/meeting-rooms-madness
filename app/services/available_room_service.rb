class AvailableRoomService
  def self.find_next_available_room_for(date, duration, projector_required)
    instance = new(date, duration)

    if projector_required
      instance.find_next_available_room_with_projector
    else
      instance.find_next_available_room
    end
  end

  def initialize(date, duration)
    @date     = date
    @duration = duration
  end

  def find_next_available_room
    eligible_rooms.map do |room_id, free_hashes|
      room = Room.find_by_id(room_id)

      [room, first_available_slot_for(room, free_hashes)]
    end
  end

  def find_next_available_room_with_projector
    find_next_available_room.select {|room, _| room.has_projector?}
  end

  private

  def eligible_rooms
    Api::FreeBusy.all_free_slots(Room.all, @date).select do |room_id, free_hashes|
      free_hashes.any?{|free_hash| free_hash[:duration] >= @duration}
    end
  end

  def first_available_slot_for(room, free_hashes)
    first_eligible_slot = free_hashes.detect{|free_hash| free_hash[:duration] >= @duration}

    {
      start: first_eligible_slot[:start],
        end: first_eligible_slot[:start] + @duration
    }

  end

end
