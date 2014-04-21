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
      Log.new 'querying WakaTime actions'

      time = Benchmark.realtime do
        @actions = @client.actions(project: @project)
        @actions.keep_if { |a| a['project'] == @project }
      end

      Log.new "API took #{time}s"
      @actions_with_durations = Actions.new.actions_to_durations(@actions)
      @total_time = sum_actions @actions_with_durations

      Log.new "Total Recorded time #{ChronicDuration.output @total_time}", :red
    end

    def relevant_actions(commit, file)
      relevant_actions = @actions_with_durations.select do |action|

        action['file'] == File.expand_path(file[:name]) &&
          Time.at(action['time']) <= commit.date
      end
      if file[:dependent_commit]
        relevant_actions = relevant_actions.select do |action|
          Time.at(action['time'])  >= file[:dependent_commit].date
        end
      end
      relevant_actions
    end

    def sum_actions(actions)
      actions.map { |action| action['duration'] }
      .compact
      .reduce { |a, e| a + e }.to_f
    end

    def process
      @commits.each do |commit|
        commit_time = 0.0
        if !commit.files.empty?
          commit.files.each_with_index do |file, i|
            time = sum_actions relevant_actions(commit, file)
            commit.files[i][:time_in_seconds] += time
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
  end
end
