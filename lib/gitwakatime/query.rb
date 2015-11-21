require 'benchmark'
require 'colorize'
require 'active_support/core_ext/time'

module GitWakaTime
  # Integrates the nested hash from mapper with heartbeats api
  class Query
    def initialize(commits, files, project, start_at: nil, end_at: nil)
      @start_at = start_at
      @end_at = end_at
      @commits = commits
      @files = files
      @project   = project
      time_range unless !@end_at.nil? && !@start_at.nil?
      @requests = RequestBuilder.new(@start_at, @end_at, project).call
    end

    # TODO: Refactor this into own class
    def time_range
      commits    = @commits.select_map(:date).sort
      d_commits  = @files.select_map(:dependent_date).compact.sort
      timestamps = (commits + d_commits.flatten).uniq.sort

      # Don't query before the Wakatime Epoch
      first_commit_at = timestamps.first
      @start_at = if first_commit_at && first_commit_at >= Time.new(2013, 5, 1)
                    first_commit_at
                  else
                    Time.new(2013, 5, 1)
                  end
      @end_at = timestamps.last || Time.now
    end

    def get
      @requests.each do |params|
        Log.new "Gettting heartbeats
         #{params[:date]}".red
        Durations.new(params).load_heartbeats
      end

      Durations.new(
        heartbeats: heartbeats.where('duration <= 0')
      ).heartbeats_to_durations
      heartbeats.all
    end

    def heartbeats
      Heartbeat.where(
        'time >= ? and time <= ? ', @start_at, @end_at
      ).where(project: @project)
    end
  end
end
