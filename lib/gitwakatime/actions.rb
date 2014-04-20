module GitWakaTime
  # Extract Duration Data from Actions for the WAKATIME API
  module Actions
    def actions_to_durations(actions, project = nil, timeout = nil)
      durations = []
      current = nil
      chart_filters = {  'writes' =>  {} }

      actions.each do | action |
        # the first action just sets state and does nothing
        if current

          # get duration since last action
          duration = round(action.time, 2) - round(current['time'], 2)

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
        current = action.to_dict(%w(branch project time file language))
        del current['id']

        durations
      end
    end
  end
end
