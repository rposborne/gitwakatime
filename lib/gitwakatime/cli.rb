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
      Log.new 'creating commit map'
      @mapper   = Mapper.new(root_path)

      @commits_with_duration = Timer.new(
        @mapper.commits,
        File.basename(root_path)
      ).process

      Log.new("Total Commited Time #{ChronicDuration.output @commits_with_duration
                  .map { |c| c.time_in_seconds }
              .reduce { |a, e| a + e }.to_f} ".red
              )

      @commits_with_duration.each do |commit|
        Log.new commit.to_s
        commit.files.each do |file|
          Log.new file.to_s
        end
      end
    end
  end
end
