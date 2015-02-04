module  GitWakaTime
  class CommitedFile < Sequel::Model
    many_to_one :commit
    # No two committed files should have the same name + dependent_date this
    # means a split tree, and we should split time between the two, or more, commits.

    def before_create
      find_dependent_commit(name)
    end

    def to_s
      format('                        %-20s %-40s %-100s '.blue,
             (dependent_sha[0..8] if dependent_sha),
             ChronicDuration.output(time_in_seconds.to_f),
             name
             )
    end

    private

    def find_dependent_commit(name)
      i = 1

      # Call git log for path, loop through till we find a valid commit or run
      # out of commits to check
      commits = load_dependent_commits(name)
      begin
        commit = commits[i]

        if commit && allowed_commit(commit)
          self.dependent_date = commit.date
          self.dependent_sha = commit.sha

          # This is the magically fix for the split tree issue
          dc = CommitedFile.where(name: name, dependent_sha: commit.sha).last
          dc.update(dependent_date: dc.commit.date) if dc && dc.commit
        end

        i += 1
      end until !dependent_sha.nil? || commit.nil?
    end

    def allowed_commit(commit)
      return false if commit.sha == sha
      return false if commit.author.name != GitWakaTime.config.user_name
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
