module  GitWakaTime
  class CommitedFile < Sequel::Model
    many_to_one :commit
    # No two committed files should have the sames name + dependent_date

    def before_create
      find_dependent_commit(name)
    end

    def to_s
      format('                 %-20s %-40s %-100s '.blue,
             (dependent_sha[0..8] if dependent_sha),
             ChronicDuration.output(@time_in_seconds.to_f),
             name

             )
    end

    private

    def find_dependent_commit(name)
      i = 1
      commit = 1
      commits = load_dependent_commits(name)
      begin
        commit = commits[i]

        if commit && allowed_commit(commit)
          self.dependent_date = commit.date
          self.dependent_sha = commit.sha

          dc = CommitedFile.where(name: name, dependent_sha: commit.sha).first
          dc.update(dependent_date: dc.commit.date) if dc && dc.commit
        end

        i += 1
      end until !dependent_sha.nil? || commit.nil?
      dependent_sha
    end

    def allowed_commit(commit)
      return false if commit.sha == sha
      return false if commit.author.name != GitWakaTime.config.git.config('user.name')
      return false if commit.message.include?('Merge branch')
      true
    end

    def load_dependent_commits(name)
      GitWakaTime.config.git.log.object(sha).path(name)
    rescue Git::GitExecuteError
      puts error
      nil
    end
  end
end
