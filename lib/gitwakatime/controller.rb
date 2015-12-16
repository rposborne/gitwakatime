module GitWakaTime
  # Extract Duration Data from Heartbeats for the WAKATIME API
  class Controller
    attr_accessor :time_range, :heartbeats, :relevant_commits, :project

    def initialize(path: '.', date: nil)
      @path = path
      GitWakaTime.config.setup_local_db
      GitWakaTime.config.root = path
      GitWakaTime.config.load_config_yaml
      GitWakaTime.config.git = Git.open(path)
      GitWakaTime::Query.new(date, Date.today, @project).call

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
    end

    def timer
      Timer.new(
        @relevant_commits.all, Heartbeat
      ).process
    end
  end
end
