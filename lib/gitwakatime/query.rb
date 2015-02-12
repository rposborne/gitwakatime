require 'benchmark'
require 'colorize'
require 'active_support/core_ext/time'

module GitWakaTime
  # Integrates the nested hash from mapper with actions api
  class Query
    def initialize(commits, files, project, _path = nil)
      @commits   = commits
      @files = files
      @api_limit = 35
      @project   = project
      @requests   = build_requests
    end

    def time_range
      commits    = @commits.select_map(:date).sort
      d_commits  = @files.select_map(:dependent_date).compact.sort
      timestamps = (commits + d_commits.flatten).uniq.sort

      # Don't query before the Wakatime Epoch
      @start_at = timestamps.first >= Time.new(2013, 5, 1) ? timestamps.first : Time.new(2013, 5, 1)
      @end_at = timestamps.last
    end

    def get
      @requests.each do |params|
        Log.new "Requesting actions #{params[:start].to_date} to #{params[:end].to_date}".red
        Durations.new(params).load_actions
      end

      Durations.new(actions: actions.where('duration <= 0')).actions_to_durations
      actions.all
    end

    def actions
      Action.where('time >= ? and time <= ? ', @start_at, @end_at).where(project: @project)
    end

    def build_requests
      time_range

      # Always have a date range great than 1 as the num request will be 0/1 otherwise
      num_requests = ((@end_at.to_date + 1) - @start_at.to_date) / @api_limit
      i = 0

      request_params = num_requests.to_f.ceil.times.map do

        params = {
          start: (@start_at.to_date + (i * @api_limit)).to_time.beginning_of_day,
          end:  (@start_at.to_date + ((i + 1) * @api_limit)).to_time.end_of_day,
          project: @project,
          show: 'file,branch,project,time,id'
        }
        i += 1
        params

      end
      request_params
    end
  end
end
