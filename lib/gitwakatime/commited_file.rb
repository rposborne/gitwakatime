module  GitWakaTime
  class CommitedFile
    attr_reader :name, :dependent_commit, :git
    attr_accessor :time_in_seconds
    def initialize(args)
      @git = args[:git]
      @name = args[:name]
      @commit = args[:commit]
      @time_in_seconds = 0

      @dependent_commit = find_dependent_commit(name)
    end

    def to_s
      format('                 %-20s %-40s %-100s '.blue,
             (dependent_commit.sha[0..8] if @dependent_commit),
             ChronicDuration.output(@time_in_seconds.to_f),
             name

             )
    end

    private

    def find_dependent_commit(name)
      i = 1
      dependent = nil
      commit = 1

      begin
        commit = load_dependent_commit(name, i: i)
        dependent = Commit.new(@git, commit, false) if allowed_commit(commit)
        i += 1
      end until !dependent.nil? || commit.nil?
      dependent
    end

    def allowed_commit(commit)
      return false if commit.nil?
      return false if commit.author.name != @git.config('user.name')
      return false if commit.message.include?('Merge branch')
      true
    end

    def load_dependent_commit(name, i: 1)
      @git.log.object(@commit.sha).path(name)[i]
    rescue Git::GitExecuteError
      puts error
      nil
    end
  end
end
