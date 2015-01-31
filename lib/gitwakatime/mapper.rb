module GitWakaTime
  # Th
  class Mapper
    attr_accessor :commits, :git
    def initialize(path, commits: 500, start_at: Date.today)
      Log.new 'Mapping commits for dependent commits'
      time = Benchmark.realtime do
        @git = if File.directory?(File.join(path, '.git'))
                 Git.open(path)
        else
          Git.bare(path)
        end

        logs =  @git.log(commits).since(start_at).until(Date.today)

        @commits = logs.map do |git_commit|
          next if git_commit.author.name != @git.config('user.name')
          Commit.new(@git, git_commit)
        end.compact
      end
      Log.new "Map Completed took #{time}s"
    end
  end
end
