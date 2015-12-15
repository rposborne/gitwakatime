require 'benchmark'
require 'colorize'

module GitWakaTime
  # Integrates the nested hash from mapper with heartbeats api
  class Request
    def initialize(args)
      @args = args
      @heartbeats = []
      @session     = Wakatime::Session.new(api_key: GitWakaTime.config.api_key)
      @client      = Wakatime::Client.new(@session)
    end

    def call
      unless cached?
        Log.new "Gettting heartbeats #{@args[:date]}".red
        time = Benchmark.realtime do
          @heartbeats = @client.heartbeats(@args)
        end

        Log.new "API took #{time}s"
      end
      true
    end

    private

    def cached?
      max_local_timetamp = Heartbeat.max(:time)
      return false if max_local_timetamp.nil?
      @max_local_timetamp ||= (Time.parse(max_local_timetamp + ' UTC'))

      @args[:date].to_date < @max_local_timetamp.to_date
    end
  end
end
