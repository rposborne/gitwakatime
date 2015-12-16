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
      Log.new "Gettting heartbeats #{@args[:date]}".red
      time = Benchmark.realtime do
        @result = @client.heartbeats(@args) || []
      end
      Log.new "API took #{time}s"

      @result
    end
  end
end
