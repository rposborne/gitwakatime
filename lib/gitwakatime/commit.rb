module GitWakaTime
  class Commit
    def initialize(git, commit)
      @commit = commit
      @git = git
    end

    def files
      return [] unless @commit.parent
      @commit.diff_parent.stats[:files].keys.map do |file|
        { name: file , dependent_commit: dependent_commit(file) }
      end
    end

    def to_hash
      {
        time_in_seconds: time_in_seconds,
        sha1: @commit.sha,
        commited_at: @commit.date,
        message: @commit.message,
        files: files,
        dependent_commits: []
      }
    end

    def time_in_seconds
      0
    end

    private

    def dependent_commit(file)
      Commit.new(@git, @git.log(100).object(file)[1]).to_hash
    rescue Git::GitExecuteError
      nil
    end
  end
end
