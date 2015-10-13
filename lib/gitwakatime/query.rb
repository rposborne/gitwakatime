require 'benchmark'
require 'colorize'
require 'active_support/core_ext/time'

module GitWakaTime
  # Integrates the nested hash from mapper with heartbeats api
  class Query
    def initialize(commits, files, project, start_at: nil, end_at: nil)
      @start_at = start_at
      @end_at = end_at
      @commits   = commits
      @files = files
      @api_limit = 1 # API ONLY ACCEPTS 1 day
      @project   = project
      @requests   = build_requests
    end

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
      @end_at = timestamps.last
    end

    def get
      @requests.each do |params|
        Log.new "Gettting heartbeats
         #{params[:date].to_date}".red
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

    def build_requests
      time_range unless !@end_at.nil? and !@start_at.nil?

      # Always have a date range great than 1 as the num request
      # will be 0/1 otherwise
      num_requests = ((@end_at.to_date + 1) - @start_at.to_date) / @api_limit
      i = 0

      request_params = num_requests.to_f.ceil.times.map do

        params = construct_params(i)
        i += 1
        params

      end
      request_params
    end

    def construct_params(i)
      {
        date: (@start_at.to_date + i ),
        project: @project,
        show: 'file,branch,project,time,id'
      }
    end
  end
end
