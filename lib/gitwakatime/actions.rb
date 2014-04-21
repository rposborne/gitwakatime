module GitWakaTime
  # Extract Duration Data from Actions for the WAKATIME API
  class Actions
    def initialize(args)
      fail if args[:project].nil?
      @project = args[:project]
      @args = args
      @session     = Wakatime::Session.new(
        api_key: '1ce219c6-73ec-4ed7-be64-11fbfcc8c9d7'
      )
      @client      = Wakatime::Client.new(@session)
      load_actions
    end

    def load_actions
      Log.new "querying WakaTime actions for #{@project}"
      time = Benchmark.realtime do
        @actions = @client.actions(@args)
        # remove returned actions that do not have the project we want
        @actions.keep_if { |a| a['project'] == @project }
      end
      Log.new "API took #{time}s"
    end

    def actions_to_durations(project = nil, timeout = 15)
      durations = []
      current = []
      @actions.each do | action |
        # the first action just sets state and does nothing
        unless current.empty?

          # get duration since last action
          duration = action.time.round - current['time'].round

          duration = 0.0 if duration < 0

          # duration not logged if greater than the timeout
          if duration < timeout * 60

            # add duration to current action
            current['duration'] = duration

            # log current action as a duration
            durations << current
          end
        end
        # set state (re-start the clock)
        current = action
        current.delete('id')

      end
      durations
    end
  end
end
