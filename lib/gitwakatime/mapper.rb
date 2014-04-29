module GitWakaTime
  # Th
  class Mapper
    attr_accessor :commits, :git
    def initialize(path, commits = 100)
      Log.new 'Mapping commits for dependent commits'
      time = Benchmark.realtime do
        @git = Git.open(path)
        # TODO: Expose since timestamp as a CLI option
        # TODO: Expose number of commits as a CLI option
        first_of_month = Date.new(Date.today.year, Date.today.month, 1)

        logs =  @git.log(commits).since(first_of_month)

        @commits = logs.map do |git_commit|
          Commit.new(@git, git_commit)
        end
      end
      Log.new "Map Completed took #{time}s"
    end
  end
end
