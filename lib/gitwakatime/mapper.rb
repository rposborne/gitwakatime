module GitWakaTime
  # Th
  class Mapper
    attr_accessor :commits, :git
    def initialize(commits: 500, start_at: Date.today)
      Log.new 'Mapping commits for dependent commits'
      time = Benchmark.realtime do
        g = GitWakaTime.config.git
        project = File.basename(g.dir.path)
        logs =  g.log(commits).since(start_at).until(Date.today)

        @commits = logs.map do |git_c|

          next if git_c.author.name != GitWakaTime.config.user_name
          Commit.find_or_create(
             sha: git_c.sha,
             project: project
             ) do |c|
            c.update(
             author: git_c.author.name,
             message: git_c.message,
             date: git_c.date
            )
          end
        end.compact
      end
      Log.new "Map Completed took #{time}s with #{Commit.count}"
    end
  end
end
