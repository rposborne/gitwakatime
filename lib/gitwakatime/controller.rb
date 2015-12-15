module GitWakaTime
  # Extract Duration Data from Heartbeats for the WAKATIME API
  class Controller
    def initialize(path: '.', date: nil)
      @path = path
      GitWakaTime.config.setup_local_db
      GitWakaTime.config.root = path
      GitWakaTime.config.load_config_yaml
      GitWakaTime.config.git = Git.open(path)
      @git_map = Mapper.new(start_at: date)
      @project = File.basename(GitWakaTime.config.git.dir.path)
      @relevant_commits = Commit.where(
        'project = ?', @project
      )

      # Scope by date if one has been passed
      @relevant_commits = @relevant_commits.where('date > ? ', date) if date

      @files = CommitedFile.where(
        'commit_id IN ?', @relevant_commits.select_map(:id)
      ).where('project = ?', @project)

      @time_range = GitWakaTime::TimeRangeEvaluator.new(
        commits: @relevant_commits,
        files: @files
      )

      @heartbeats = Query.new(@time_range, @project).call
    end

    def timer
      Timer.new(
        @relevant_commits.all, Heartbeat
      ).process
    end
  end
end
