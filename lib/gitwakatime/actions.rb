module GitWakaTime
  # Extract Duration Data from Actions for the WAKATIME API
  class Actions
    def actions_to_durations(actions, project = nil, timeout = 15)
      durations = []
      current = []
      chart_filters = {  'writes' =>  {} }

      actions.each do | action |
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
            durations.append(current)
          end
        end
        # is this action a file or project
        if project
          id = action.file
        else
          id = action.project

          id = 'Unknown Project' unless id

          # update projects that have writes
          chart_filters['writes'][id] = True if action.is_write

        end
        # set state (re-start the clock)
        current = action
        current.delete('id')

        durations
      end
    end
  end
end
