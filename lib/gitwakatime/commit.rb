
module GitWakaTime
  class Commit < Sequel::Model
    # attr_accessor :raw_commit, :sha, :date, :message, :files, :time_in_seconds, :git, :author
    one_to_many :commited_files
    def after_create
      get_files
    end

    def inspect
      [sha[0..8], time_in_seconds]
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

    private

    def get_files
      @raw_commit = GitWakaTime.config.git.gcommit(sha)
      # TODO: Assume gap time to lookup time prior to first commit.
      if @raw_commit.parent
        update(parent_sha: @raw_commit.parent.sha)

        @raw_commit.diff_parent.stats[:files].keys.map do |file|
          CommitedFile.create(commit_id: id, name: file, sha: sha, project: project)
        end
    end
    end
  end
end
