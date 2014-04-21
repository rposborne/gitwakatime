require 'benchmark'
module GitWakaTime
  # Integrates the nested hash from mapper with actions api
  class Timer
    def initialize(commits, project)
      @commits = commits
      @actions_with_durations = Actions.new(project: project).actions_to_durations
    end

    def total
      @total_time = sum_actions @actions_with_durations
      Log.new "Total Recorded time #{ChronicDuration.output @total_time}", :red
    end

    def relevant_actions(commit, file)
      relevant_actions = @actions_with_durations.select do |action|
        action['file'] == File.expand_path(file.name) &&
          Time.at(action['time']) <= commit.date
      end

      if file.dependent_commit
        relevant_actions = relevant_actions.select do |action|
          Time.at(action['time'])  >= file.dependent_commit.date
        end
      end

      relevant_actions
    end

    def process
      total
      @commits.each do |commit|
        commit_time = 0.0
        if !commit.files.empty?
          commit.files.each_with_index do |file, i|
            time = sum_actions relevant_actions(commit, file)
            commit.files[i].time_in_seconds += time
            commit_time += time
          end
        else
          prior_actions = @actions_with_durations.select do |action|
            Time.at(action['time']) <= commit.date
          end

          commit_time = sum_actions(prior_actions)
        end

        commit.time_in_seconds = commit_time.to_f
      end
    end

    private

    def sum_actions(actions)
      actions.map { |action| action['duration'] }
      .reduce(:+).to_f
    end
  end
end
