module GitWakaTime
  # Return a array of dates to be look / timed against
  class TimeRangeEvaluator
    attr_reader :start_at, :end_at, :project

    def initialize(commits:, files:, project:)
      @commits = commits
      @files = files
      @project   = project

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
      @end_at = timestamps.last || Time.now
    end
  end
end
