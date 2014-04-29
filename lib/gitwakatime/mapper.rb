module GitWakaTime
  class Mapper
    attr_accessor :commits, :git
    def initialize(path, commits = 20)
      Log.new 'Mapping commits for dependent commits'
      time = Benchmark.realtime do
        @git = Git.open(path)
        logs =  @git.log(20)

        @commits = logs.map do |git_commit|
          Commit.new(@git, git_commit)
        end
      end
      Log.new "Map Completed took #{time}s"
    end
  end
end
