module GitWakaTime
  # Th
  class Mapper
    attr_accessor :commits, :git
    def initialize(commits: 500, start_at: Date.today)
      Log.new 'Mapping commits for dependent commits'
      time = Benchmark.realtime do
        g = GitWakaTime.config.git
        project = File.basename(GitWakaTime.config.git.dir.path)
        logs =  g.log(commits).since(start_at).until(Date.today)

        @commits = logs.map do |c|

          next if c.author.name != g.config('user.name')
          Commit.find_or_create(
             sha: c.sha,
             project: project
             ).update(
             author: c.author.name,
             message: c.message,
             date: c.date
            )
        end.compact
      end
      Log.new "Map Completed took #{time}s with #{Commit.count}"
    end
  end
end
