require 'benchmark'
require 'colorize'

module GitWakaTime
  # Integrates the nested hash from mapper with heartbeats api
  class Query
    def initialize(range, project)
      @start_at = range.start_at
      @end_at = range.end_at
      @project = project
      @requests = RequestBuilder.new(@start_at, @end_at).call
    end

    def call
      @requests.each do |params|
        Durations.new(params).load_heartbeats
      end

      Durations.new(
        heartbeats: heartbeats.where('duration <= 0')
      ).heartbeats_to_durations

      heartbeats.where(project: @project).all
    end

    private

    def heartbeats
      Heartbeat.where(
        'time >= ? and time <= ? ', @start_at, @end_at
      )
    end
  end
end
