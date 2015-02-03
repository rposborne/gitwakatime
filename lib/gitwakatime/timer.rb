require 'benchmark'
require 'colorize'
require 'active_support/core_ext/time'

module GitWakaTime
  # Integrates the nested hash from mapper with actions api
  class Timer
    def initialize(commits, actions_with_durations, project)
      @commits = commits
      @actions_with_durations   = actions_with_durations
      @project   = project
    end

    def total
      total_time = sum_actions @actions_with_durations
      Log.new "Total Recorded time #{ChronicDuration.output total_time}", :red
    end

    def total_commited
      total_commited = ChronicDuration.output(@commits_with_duration
                                               .map(&:time_in_seconds).compact
                                               .reduce(:+).to_f)
      Log.new "Total Commited Time #{total_commited} ".red
    end

    def process
      @commits_with_duration = @commits.each do |commit|

        if commit.commited_files.count > 0 || commit.parent_sha
          commit.commited_files.each_with_index do |file, _i|
            time = sum_actions relevant_actions(commit, file)
            file.time_in_seconds = time
            commit.time_in_seconds = time

            file.save
          end
          commit.save
        else
          commit.time_in_seconds = sum_actions(actions_before(@actions_with_durations, commit.date))
        end
      end.compact
      total
      total_commited
      @commits_with_duration
      @commits_with_duration_by_date = @commits_with_duration.group_by { |c| c.date.to_date }
    end

    private

    def relevant_actions(commit, file)
      # The file should be the same file as we expect
      # TODO: Might need to pass root_path down
      actions = @actions_with_durations.select do |action|
        action['file'].include?(file.name)
      end

      # The timestamps should be before the expected commit
      actions = actions_before(actions, commit.date)

      # If this file had an earlier commit ensure the actions timestamp
      # is after that commit
      if file.dependent_date
        actions = actions_after(actions, file.dependent_date)
      end
      actions
    end

    def actions_before(actions, date)
      actions.select do |action|
        Time.at(action['time']) <= date
      end
    end

    def actions_after(actions, date)
      actions.select do |action|
        Time.at(action['time']) >= date
      end
    end

    def sum_actions(actions)
      actions.map { |action| action['duration'] }
      .reduce(:+).to_i
    end
  end
end
