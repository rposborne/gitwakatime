require 'benchmark'
require 'colorize'
require 'active_support/core_ext/time'

module GitWakaTime
  # Integrates the nested hash from mapper with heartbeats api
  class Timer
    def initialize(commits, heartbeats_with_durations, project)
      @commits = commits
      @heartbeats_with_durations   = heartbeats_with_durations
      @project   = project
    end

    def total
      total_time = sum_heartbeats @heartbeats_with_durations
      Log.new "Total Recorded time #{ChronicDuration.output total_time}", :red
    end

    def total_commited
      total_commited = ChronicDuration.output(@commits_with_duration
                                              .map(&:time_in_seconds).compact
                                              .reduce(:+).to_f)
      Log.new "Total Committed Time #{total_commited} ".red
    end

    def process
      @commits_with_duration = @commits.each do |commit|

        if commit.commited_files.count > 0 || commit.parent_sha
          commit.commited_files.each_with_index do |file, _i|
            time = sum_heartbeats relevant_heartbeats(commit, file)
            file.time_in_seconds = time
            commit.time_in_seconds = time

            file.save
          end
          commit.save
        else
          commit.time_in_seconds = sum_heartbeats(
            heartbeats_before(@heartbeats_with_durations, commit.date)
          )
        end
      end.compact
      total
      total_commited
      @commits_with_duration.group_by { |c| c.date.to_date }
    end

    private

    def relevant_heartbeats(commit, file)
      # The file should be the same file as we expect
      # TODO: Might need to pass root_path down
      heartbeats = @heartbeats_with_durations.select do |heartbeat|
        heartbeat[:entity].include?(
          File.join(File.basename(GitWakaTime.config.git.dir.path), file.name)
        )
      end

      # The timestamps should be before the expected commit
      heartbeats = heartbeats_before(heartbeats, commit.date)

      # If this file had an earlier commit ensure the heartbeats timestamp
      # is after that commit
      if file.dependent_date
        heartbeats = heartbeats_after(heartbeats, file.dependent_date)
      end
      heartbeats
    end

    def heartbeats_before(heartbeats, date)
      heartbeats.select do |heartbeat|
        Time.at(heartbeat[:time]) <= date
      end
    end

    def heartbeats_after(heartbeats, date)
      heartbeats.select do |heartbeat|
        Time.at(heartbeat[:time]) >= date
      end
    end

    def sum_heartbeats(heartbeats)
      heartbeats.map { |heartbeat| heartbeat[:duration] }
      .reduce(:+).to_i
    end
  end
end
