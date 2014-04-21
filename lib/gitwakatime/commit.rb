module GitWakaTime
  class Commit
    attr_accessor :sha, :date, :message, :files, :time_in_seconds

    def initialize(git, commit, load_files = true)
      @raw_commit      = commit
      @sha             = @raw_commit.sha
      @date            = @raw_commit.date
      @message         = @raw_commit.message
      @time_in_seconds = 0
      @git             = git
      @load_files      = load_files
      @files = load  if load_files
    end

    def load
      return [] unless @raw_commit.parent
      @raw_commit.diff_parent.stats[:files].keys.map do |file|
        {
          name: file ,
          time_in_seconds: 0,
          dependent_commit: (dependent_commit(file) if @load_files)
        }
      end
    end

    def to_hash
      {
        time_in_seconds: @time_in_seconds,
        sha1: @sha,
        commited_at: @commited_at,
        message: @message,
        files: @files,
        dependent_commits: []
      }
    end

    private

    def dependent_commit(file)
      @dependent_commit = load_dependent_commit(file)
      Commit.new(@git, @dependent_commit , false) if @dependent_commit
    end

    def load_dependent_commit(file)
      @git.log(100).until(@raw_commit.date.to_s).object(file)[1]
    rescue Git::GitExecuteError
      nil
    end
  end
end
