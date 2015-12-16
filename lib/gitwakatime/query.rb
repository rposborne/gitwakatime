require 'benchmark'
require 'colorize'

module GitWakaTime
  # Integrates the nested hash from mapper with heartbeats api
  class Query
    def initialize(start_at, end_at, project)
      @start_at = start_at
      @end_at = end_at
      @project = project
      @requests = RequestBuilder.new(@start_at, @end_at).call
      Log.new "Loading Committed time from #{@start_at} to #{@end_at}".red
    end

    def call
      @requests.each do |params|
        next if cached?(params[:date])
        persist_heartbeats_localy(Request.new(params).call)
      end

      DurationsCalculator.new(heartbeats: local_heartbeats.where('duration <= 0') ).heartbeats_to_durations
      local_heartbeats.where(project: @project).all
    end

    def cached?(date)
      max_local_timestamp = Heartbeat.max(:time)
      return false if max_local_timestamp.nil?
      @max_local_timestamp ||= (Time.parse(max_local_timestamp + ' UTC'))
      date.to_date < @max_local_timestamp.to_date
    end

    private

    def persist_heartbeats_localy(heartbeats)
      heartbeats.map do |heartbeat|
        heartbeat['uuid'] = heartbeat['id']
        heartbeat['time'] = Time.at(heartbeat['time'])
        heartbeat.delete('id')
        Heartbeat.find_or_create(uuid: heartbeat['uuid']) do |a|
          a.update(heartbeat)
        end
      end
    end

    def local_heartbeats
      Heartbeat.where(
        'time >= ? and time <= ? ', @start_at, @end_at
      )
    end
  end
end
