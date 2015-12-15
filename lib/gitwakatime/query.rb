require 'benchmark'
require 'colorize'

module GitWakaTime
  # Integrates the nested hash from mapper with heartbeats api
  class Query
    def initialize(range, project, arg = {})
      @start_at = range.start_at
      @end_at = range.end_at
      @project = project
      @requests = RequestBuilder.new(@start_at, @end_at).call
      @session     = Wakatime::Session.new(api_key: GitWakaTime.config.api_key)
      @client      = Wakatime::Client.new(@session)
    end

    def call
      heartbeats = []
      @requests.each do |params|
        heartbeats << load_heartbeats(params)
      end

      Durations.new(
        heartbeats: local_heartbeats.where('duration <= 0')
      ).heartbeats_to_durations

      local_heartbeats.where(project: @project).all
    end

    private

    def load_heartbeats(params)
      unless cached?(params)
        Log.new "Gettting heartbeats #{params[:date]}".red
        time = Benchmark.realtime do
          @heartbeats = @client.heartbeats(params)
        end

        Log.new "API took #{time}s"
        persist_heartbeats_localy(@heartbeats)
      end
       @heartbeats
    end

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

    def cached?(params)
      max_local_timetamp = Heartbeat.max(:time)
      return false if max_local_timetamp.nil?
      @max_local_timetamp ||= (Time.parse(max_local_timetamp))

      params[:date].to_date < @max_local_timetamp.to_date
    end

    def local_heartbeats
      Heartbeat.where(
        'time >= ? and time <= ? ', @start_at, @end_at
      )
    end
  end
end
