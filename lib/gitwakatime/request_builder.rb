module GitWakaTime
  # Build an array of hash's (params) that can be iterated over for the
  # wakatime API.
  class RequestBuilder
    WAKATIME_EPOCH = Date.new(2013, 5, 1)
    API_LIMIT = 1 # API ONLY ACCEPTS 1 day

    def initialize(start_at, end_at)
      @start_at = [start_at.to_date, WAKATIME_EPOCH].max
      @end_at = end_at.to_date
    end

    def call
      # Always have a date range great than 1 as the num request
      # will be 0/1 otherwise
      num_requests = ((@end_at + 1) - @start_at) / API_LIMIT
      i = 0

      request_params = num_requests.to_f.ceil.times.map do
        params = construct_params(i)
        i += 1
        params
      end
      request_params
    end

    private

    def construct_params(i)
      {
        date: (@start_at.to_date + i).to_date,
        show: 'file,branch,project,time,id'
      }
    end
  end
end
