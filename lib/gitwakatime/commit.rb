module GitWakaTime
  class Commit
    def initialize(git, commit, load_files = true)
      @commit = commit
      @git = git
      @load_files = load_files
    end

    def files
      return [] unless @commit.parent
      @commit.diff_parent.stats[:files].keys.map do |file|
        {
          name: file ,
          dependent_commit: (dependent_commit(file) if @load_files)
        }
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
      @dependent_commit = load_dependent_commit(file)
      Commit.new(@git, @dependent_commit , false).to_hash if @dependent_commit
   end

    def load_dependent_commit(file)
      @git.log(100).object(file)[1]
    rescue Git::GitExecuteError
      nil
    end
  end
end
