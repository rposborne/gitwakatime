module GitWakaTime
  ##
  # Cache git commit and correlate it's children
  #
  class Commit < Sequel::Model
    one_to_many :commited_files
    def after_create
      extract_changed_files if GitWakaTime.config.git
    end

    def to_s
      format('        %-8s %8s %-30s %-80s'.green,
             sha[0..8],
             date,
             ChronicDuration.output(time_in_seconds.to_i),
             message
            )
    end

    def oldest_dependent
      @files.sort { |f| f.commit.date }.first
    end

    def time_in_seconds
      commited_files.map(&:time_in_seconds).compact.inject(:+)
    end

    private

    def extract_changed_files
      @raw_commit = GitWakaTime.config.git.gcommit(sha)
      # TODO: Assume gap time to lookup time prior to first commit.
      return unless @raw_commit.parent
      update(parent_sha: @raw_commit.parent.sha)

      @raw_commit.diff_parent.stats[:files].keys.map do |file|
        CommitedFile.find_or_create(commit_id: id, name: file) do |c|
          c.update(sha: sha, project: project)
        end
      end
    end
  end
end
