class Event
  def self.all_of_today(room)
    all_between(room, Time.current, Time.current.end_of_day)
  end

  def self.all_between(room, from_time, to_time)
    events     = []
    page_token = nil

    begin
      result = Api.client.execute!(query(room, from_time, to_time, page_token))
      events += result.data.items
    end while page_token = result.data.next_page_token

    events.map{|event| new(event)}
  end

  def self.query(room, from_time, to_time, page_token=nil)
    {
      api_method: Api.calendar_api.events.list,
      parameters: {
        calendarId: room.id,
        maxResults: 100,
        singleEvents: true,
        orderBy: 'startTime',
        timeMin: from_time.utc.iso8601,
        timeMax: to_time.utc.iso8601
      }
    }.merge(page_token.nil? ? {} : {pageToken: page_token})
  end

  private_class_method :query


  def initialize(event)
    @raw_event_hash = event.to_hash
  end

  %w[status location creator attendees summary description].each do |method|
    define_method(method) do
      @raw_event_hash[method]
    end
  end

  def start_time
    DateTime.parse(@raw_event_hash['start'].values.first)
  end

  def end_time
    DateTime.parse(@raw_event_hash['end'].values.first)
  end

  def current?
    Time.current >= start_time && Time.current < end_time
  end

  def inspect
    "#<Event: #location='#{location}' #summary='#{summary}' #status='#{status}' #start_time='#{start_time}' #end_time='#{end_time}>"
  end
end
