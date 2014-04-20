require 'benchmark'
module GitWakaTime
  # Integrates the nested hash from mapper with actions api
  class Timer
    def initialize(commits, project = nil)
      @commits = commits
      @project = 'gitwakatime'
      @session = Wakatime::Session.new(
        api_key: '1ce219c6-73ec-4ed7-be64-11fbfcc8c9d7'
      )
      @client = Wakatime::Client.new(@session)
      load_actions
    end

    def load_actions
      GitWakaTime::Log.new 'querying WakaTime actions'

      time = Benchmark.realtime do
        @actions = @client.actions(project: @project)
      end

      GitWakaTime::Log.new "API took #{time}s"
      GitWakaTime::Log.new 'starting to calculate WakaTime durations'
      @actions_with_durations = Actions.new.actions_to_durations(@actions)
      GitWakaTime::Log.new 'calculated WakaTime durations'
    end

    def relevant_actions(commit, file)
      @actions_with_durations.select do |action|
        action['file'] == File.expand_path(file[:name]) &&
          action['time'] >= commit[:commited_at].to_i
      end
    end

    def process
      @commits.each do |commit|
        commit_time = 0.0
        commit[:files].each do |file|
          file[:time_in_seconds] = relevant_actions(commit, file)
          .map { |action| action['duration'] }
          .compact
          .reduce { |a, e| a + e }
          commit_time += file[:time_in_seconds].to_f
        end
        commit[:time_in_seconds] = commit_time.to_f
      end
    end
  end
end
