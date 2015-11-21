module  GitWakaTime
  ##
  # Determines When a file was lasted commit and stores time and hash.
  class CommitedFile < Sequel::Model
    many_to_one :commit

    # No two committed files should have the same name + dependent_date this
    # means a split tree, and we should split time between the two, or
    # more, commits.
    def before_create
      find_dependent_commit(name) if GitWakaTime.config.git
    end

    def to_s
      format('                        %-20s %-40s %-100s '.blue,
             (dependent_sha[0..8] if dependent_sha),
             ChronicDuration.output(time_in_seconds.to_f),
             name
            )
    end

    private

    # Call git log for path, loop through till we find a valid commit or run
    # out of commits to check
    def find_dependent_commit(name, i = 1)
      commits = load_dependent_commits(name)
      loop do
        commit = commits[i]

        if commit && allowed_commit(commit)
          set dependent_sha: commit.sha, dependent_date: commit.date
          check_and_correct_split_tree(commit)
        end

        i += 1
        break if !dependent_sha.nil? || commit.nil?
      end
    end

    def check_and_correct_split_tree(commit)
      # This is the magical fix for the split tree issue
      # Current though is this will fail if more than 2 split tree files
      split_tree_file = CommitedFile.where(
        name: name, dependent_sha: commit.sha
      ).first
      return unless split_tree_file && split_tree_file.commit

      if self.commit.date < split_tree_file.commit.date
        self.dependent_date = split_tree_file.commit.date
      elsif self.commit.date > split_tree_file.commit.date
        split_tree_file.update(dependent_date: commit.date)
      end
    end

    def allowed_commit(commit)
      return false if commit.sha == sha
      return false if commit.author.name != GitWakaTime.config.user_name
      return false if commit.parents.size > 1
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
