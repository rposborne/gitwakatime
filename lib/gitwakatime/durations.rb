module GitWakaTime
  # Extract Duration Data from Actions for the WAKATIME API
  class Durations
    attr_accessor :actions
    def initialize(args)
      return @actions = args[:actions] if args[:actions]
      fail if args[:project].nil?
      @project = args[:project]
      @args = args
      @session     = Wakatime::Session.new(api_key: GitWakaTime.config.api_key)
      @client      = Wakatime::Client.new(@session)
      @actions = []
    end

    def load_actions
      unless cached?

        Log.new "querying WakaTime actions for #{@project}"
        time = Benchmark.realtime do
          @actions = @client.actions(@args)

          # remove returned actions that do not have the project we want
          @actions =  @actions.keep_if do  |a|
            a['project'] == @project
          end
        end

        Log.new "API took #{time}s"
        persist_actions_localy(@actions)
      end
      true
    end

    def persist_actions_localy(actions)
      sterile_actions = actions.map do |action|
          action['uuid'] = action['id']
          action['time'] = Time.at(action['time'])
          action.delete('id')
          Action.find_or_create(uuid: action['uuid']) do |a|
            a.update(action)
          end
      end
      
    end

    def cached?
      # Check to see if this date range might be stale?
      if cached_actions.count > 0
        max_local_timetamp = (Time.parse(cached_actions.max(:time)) + 3.day).to_date
        !(@args[:start].to_date..@args[:end].to_date).include?(max_local_timetamp)
      else
        false
      end
    end

    def cached_actions
      Action.where('time >= ?',@args[:end]).where(project: @project)
    end

    def actions_to_durations(_project = nil, timeout = 15)
      durations = []
      current = nil

      @actions.each do | action |
        # the first action just sets state and does nothing
        unless current.nil?

          # get duration since last action
          duration = action.time.round - current.time.round

          duration = 0.0 if duration < 0

          # duration not logged if greater than the timeout
          if duration < timeout * 60

            # add duration to current action
            current.duration = duration

            # save to local db
            current.save

            # log current action as a duration
            durations << current
          end
        end
        # set state (re-start the clock)
        current = action

      end
      durations
    end
  end
end
