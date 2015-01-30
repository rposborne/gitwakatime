require 'benchmark'
require 'colorize'

module GitWakaTime
  # Integrates the nested hash from mapper with actions api
  class Timer
    def initialize(commits, project, _path = nil)
      @commits         = commits
      @api_limit = 30
      @project = project
      requests           = time_params

      @actions = []
      requests.each do |params|
        Log.new "Requesting actions #{params['start'].to_date} to #{params['end'].to_date}".red
        @actions = @actions.concat Actions.new(params).actions
      end

      @actions_with_durations =  Actions.new(actions: @actions).actions_to_durations
    end

    def time_params
      commits = @commits.map(&:date)
      d_commits = @commits.map do |c|
        c.files.map(&:dependent_commit).compact.map(&:date)
      end
      timestamps = (commits + d_commits.flatten).uniq
      num_requests = (timestamps.first.to_date - timestamps.last.to_date) / @api_limit
      i = 0
      request_params = num_requests.to_f.ceil.times.map do

        params = {
          'start' => (timestamps.last.to_date + (i * @api_limit)).to_time,
          'end' => (timestamps.last.to_date + ((i + 1) * @api_limit)).to_time.end_of_day,
          :project => @project
        }
        i += 1
        params

      end

      request_params
    end

    def total
      @total_time = sum_actions @actions_with_durations
      Log.new "Total Recorded time #{ChronicDuration.output @total_time}", :red
    end

    def total_commited
      @total_commited = ChronicDuration.output(@commits_with_duration
                                               .map(&:time_in_seconds)
                                               .reduce(:+).to_f)
      Log.new "Total Commited Time #{@total_commited} ".red
    end

    def process
      @commits_with_duration = @commits.each do |commit|
        if !commit.author.nil? && commit.author.name == commit.git.config('user.name')
          if !commit.files.empty?
            commit.files.each_with_index do |file, i|
              time = sum_actions relevant_actions(commit, file)
              commit.files[i].time_in_seconds += time
              commit.time_in_seconds += time
            end
          else
            commit.time_in_seconds = sum_actions(actions_before(commit.date))
          end
        end
      end.compact
      total
      total_commited
      @commits_with_duration
      @commits_with_duration_by_date = @commits_with_duration.group_by { |c| c.date.to_date }
    end

    private

    def relevant_actions(commit, file)
      # The timestamps should be before the expected commit
      actions = actions_before(commit.date)

      # The file should be the same file as we expect
      # TODO: Might need to pass root_path down
      actions = actions.select do |action|
        action['file'] == File.join(file.git.dir.path, file.name)
      end
      # If this file had an earlier commit ensure the actions timestamp
      # is after that commit
      if file.dependent_commit
        actions = actions.select do |action|
          Time.at(action['time'])  >= file.dependent_commit.date
        end
      end

      actions
    end

    def actions_before(date)
      @actions_with_durations.select do |action|
        Time.at(action['time']) <= date
      end
    end

    def sum_actions(actions)
      actions.map { |action| action['duration'] }
      .reduce(:+).to_f
    end
  end
end
