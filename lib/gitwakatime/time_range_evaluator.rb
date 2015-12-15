module GitWakaTime
  #
  class TimeRangeEvaluator
    # The first recorded time stamp in Wakatime database happened the day after
    # this date
    WAKATIME_EPOCH = Time.new(2013, 5, 1)

    attr_reader :start_at, :end_at

    def initialize(commits:, files:)
      @start_at = @end_at = Time.now
      @commits = commits
      @files = files

      timestamps = [
        @commits.min(:date),
        @files.min(:dependent_date),
        @commits.max(:date),
        @files.max(:dependent_date)
      ].compact.map { |s| Time.parse(s) }

      # Don't query before the Wakatime Epoch
      return if timestamps.empty?
      @start_at = [timestamps.min, WAKATIME_EPOCH].max
      @end_at = timestamps.max || Time.now
    end
  end
end
