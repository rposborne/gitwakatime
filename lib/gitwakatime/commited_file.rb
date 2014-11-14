module  GitWakaTime
  class CommitedFile
    attr_reader :name, :dependent_commit, :git
    attr_accessor :time_in_seconds
    def initialize(args)
      @git = args[:git]
      @name = args[:name]
      @parent_commit = args[:parent_commit]
      @time_in_seconds = 0
      @find_dependent = args[:dependent] || true

      write_dependent_commit(name) if @find_dependent
    end

    def to_s
      format('    %-40s %-40s %-20s'.blue,
             ChronicDuration.output(time_in_seconds.to_f),
             name,
             (dependent_commit.sha[0..8] if @dependent_commit)
             )
    end

    private

    def write_dependent_commit(name)
      commit = load_dependent_commit(name)
      @dependent_commit = Commit.new(@git, commit, false) if commit
    end

    def load_dependent_commit(name)
      @git.log(100).until(@parent_commit.date.to_s).object(name)[1]
    rescue Git::GitExecuteError
      nil
    end
  end
end
