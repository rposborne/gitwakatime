require 'awesome_print'
module GitWakaTime
  class Mapper
    attr_accessor :commits
    def initialize(path)
      # current_project = File.basename(path)
      @git = Git.open(path)
      start_date = '1 weeks ago'
      logs =  @git.log(100).since(start_date)

      @commits = logs.map do |git_commit|
        Commit.new(@git, git_commit)
      end
    end
  end
end
