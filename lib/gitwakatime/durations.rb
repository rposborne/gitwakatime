module GitWakaTime
  # Extract Duration Data from Heartbeats for the WAKATIME API
  class Durations
    attr_accessor :heartbeats
    def initialize(args)
      return @heartbeats = args[:heartbeats] if args[:heartbeats]
      fail if args[:project].nil?
      @project = args[:project]
      @args = args
      @session     = Wakatime::Session.new(api_key: GitWakaTime.config.api_key)
      @client      = Wakatime::Client.new(@session)
      @heartbeats = []
    end

    def load_heartbeats
      unless cached?

        Log.new "querying WakaTime heartbeats for #{@project}"
        time = Benchmark.realtime do
          @heartbeats = @client.heartbeats(@args)

          # remove returned heartbeats that do not have the project we want
          @heartbeats =  @heartbeats.keep_if do  |a|
            a['project'] == @project
          end
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
      # Check to see if this date range might be stale?
      if cached_heartbeats.count > 0
        max_local_timetamp = (
          Time.parse(cached_heartbeats.max(:time)) + 15.day
        ).to_date
        !(
          @args[:start].to_date..@args[:end].to_date
        ).include?(max_local_timetamp)
      else
        false
      end
    end

    def cached_heartbeats
      Heartbeat.where('time >= ?', @args[:end]).where(project: @project)
    end

    def heartbeats_to_durations(_project = nil, timeout = 15)
      durations = []
      current = nil

      @heartbeats.each do | heartbeat |
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
