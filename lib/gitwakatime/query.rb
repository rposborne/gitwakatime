require 'benchmark'
require 'colorize'
require 'active_support/core_ext/time'

module GitWakaTime
  # Integrates the nested hash from mapper with actions api
  class Query
    def initialize(commits, project, _path = nil)
      @commits   = commits
      @api_limit = 15
      @project   = project
      @actions   = []
      @requests   = time_params
    end

    def get
      @requests.each do |params|
        Log.new "Requesting actions #{params[:start].to_date} to #{params[:end].to_date}".red
        @actions = @actions.concat Actions.new(params).actions
      end

      Actions.new(actions: @actions.uniq(&:id)).actions_to_durations
    end

    def time_params
      commits = @commits.map(&:date)
      d_commits = CommitedFile.select(:dependent_date).all.map { |f| f.values[:dependent_date] }.compact
      timestamps = (commits + d_commits.flatten).uniq.sort
      num_requests = (timestamps.last.to_date - timestamps.first.to_date) / @api_limit
      i = 0
      request_params = num_requests.to_f.ceil.times.map do

        params = {
          start: (timestamps.last.to_date + (i * @api_limit)).to_time.beginning_of_day,
          end:  (timestamps.last.to_date + ((i + 1) * @api_limit)).to_time.end_of_day,
          project: @project
        }
        i += 1
        params

      end
      request_params
    end
  end
end
