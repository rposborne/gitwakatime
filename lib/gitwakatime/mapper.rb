require 'awesome_print'
module GitWakaTime
  class Mapper
    attr_accessor :commits, :git
    def initialize(path)
      @git = Git.open(path)
      logs =  @git.log(20)

      @commits = logs.map do |git_commit|
        Commit.new(@git, git_commit)
      end
    end
  end
end
