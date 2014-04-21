require 'git'
require 'logger'
require 'wakatime'
require 'ap'
require 'chronic_duration'
module  GitWakaTime
  class Cli < Thor
    desc 'calc', 'Prints calc'
    method_option :file, aliases: '-f', default: '.'
    def calc
      root_path = File.expand_path(options.file)
      Log.new 'creating dependent commit map'
      @mapper   = Mapper.new(root_path)
      Log.new 'processing commit times'
      @timer    = Timer.new(@mapper.commits)

      @commits_with_duration = @timer.process

      Log.new("Total Time #{ChronicDuration.output @commits_with_duration.map { |c| c.time_in_seconds }.reduce { |a, e| a + e }.to_f} ".red)
      @commits_with_duration.each do |commit|
        puts ' %-8s %8s %-30s %-80s'.green %
        [
          commit.sha[0..8],
          commit.date,
          ChronicDuration.output(commit.time_in_seconds),
          commit.message
        ]

        commit.files.each do |file|
          puts '    %-40s %-40s %-20s'.blue % [
            ChronicDuration.output(file[:time_in_seconds].to_f),
            file[:name],
            (file[:dependent_commit].sha[0..8] if file[:dependent_commit])
          ]

        end
      end
    end
  end
end
