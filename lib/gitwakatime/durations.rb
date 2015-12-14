module GitWakaTime
  # Extract Duration Data from Heartbeats for the WAKATIME API
  class Durations
    attr_accessor :heartbeats
    def initialize(args)
      return @heartbeats = args[:heartbeats] if args[:heartbeats]
      @args = args
      @heartbeats = []
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
