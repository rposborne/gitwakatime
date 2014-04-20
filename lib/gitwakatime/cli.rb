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
      ap 'creating dependent commit map'
      @mapper   = Mapper.new(root_path)
      ap 'processing commit times'
      @timer    = Timer.new(@mapper.commits)

      @commits_with_duration = @timer.process

      @commits_with_duration.each do |commit|
         Log.new("#{commit[:sha1][0..8]} took #{ChronicDuration.output(commit[:time_in_seconds])}")
       end
    end
  end
end
