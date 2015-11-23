module GitWakaTime
  # Extract Duration Data from Heartbeats for the WAKATIME API
  class Durations
    attr_accessor :heartbeats
    def initialize(args)
      return @heartbeats = args[:heartbeats] if args[:heartbeats]
      @args = args
      @session     = Wakatime::Session.new(api_key: GitWakaTime.config.api_key)
      @client      = Wakatime::Client.new(@session)
      @heartbeats = []
    end

    def load_heartbeats
      unless cached?
        Log.new "Gettting heartbeats #{@args[:date]}".red
        time = Benchmark.realtime do
          @heartbeats = @client.heartbeats(@args)
        end

        Log.new "API took #{time}s"
        persist_heartbeats_localy(@heartbeats)
      end
      true
    end

    def persist_heartbeats_localy(heartbeats)
      heartbeats.map do |heartbeat|
        heartbeat['uuid'] = heartbeat['id']
        heartbeat['time'] = Time.at(heartbeat['time'])
        heartbeat.delete('id')
        Heartbeat.find_or_create(uuid: heartbeat['uuid']) do |a|
          a.update(heartbeat)
        end
      end
    end

    def cached?
      max_local_timetamp = Heartbeat.max(:time)
      return false if max_local_timetamp.nil?
      @max_local_timetamp ||= (Time.parse(max_local_timetamp))

      @args[:date].to_date < @max_local_timetamp.to_date
    end

    def cached_heartbeats
      Heartbeat.where('DATE(time) == ?', @args[:date]).order(Sequel.asc(:time))
    end

    def heartbeats_to_durations(timeout = 15)
      durations = []
      current = nil
      @heartbeats.each do |heartbeat|
        # the first heartbeat just sets state and does nothing
        unless current.nil?

          # get duration since last heartbeat
          duration = heartbeat.time.round - current.time.round

          duration = 0.0 if duration < 0

          # duration not logged if greater than the timeout
          if duration < timeout * 60

            # add duration to current heartbeat
            current.duration = duration

            # save to local db
            current.save

            # log current heartbeat as a duration
            durations << current
          end
        end
        # set state (re-start the clock)
        current = heartbeat
      end
      durations
    end
  end
end
