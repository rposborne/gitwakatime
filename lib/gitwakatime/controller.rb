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
        'date > ? and project = ?', date, @project
      )

      @files = CommitedFile.where(
        'commit_id IN ?',  @relevant_commits.select_map(:id)
      ).where('project = ?', @project)

      @heartbeats = Query.new(
        @relevant_commits, @files, File.basename(path)
      ).get
    end

    def timer
      Timer.new(
        @relevant_commits.all, Heartbeat
      ).process
    end
  end
end
