require 'git'
require 'logger'
require 'wakatime'
require 'ap'
require 'chronic_duration'
require 'yaml'
module  GitWakaTime
  # Provides two CLI actions init and tally
  class Cli < Thor
    include Thor::Actions
    desc 'init', 'Setups up Project for using the wakatime API
      it will also add to your git ignore file'
    method_option :file, aliases: '-f', default: '.'

    def init
      say('Adding .wakatime.yml to home directory')

      create_file File.join(Dir.home, '.wakatime.yml') do
        YAML.dump(api_key: 'Your API Key', last_commit: nil, log_level: :info)
      end
    end

    desc 'tally', 'Produce time spend for each commit and file in each commit'
    method_option :file, aliases: '-f', default: '.'
    def tally
      path , GitWakaTime.config.root = File.expand_path(options.file)
      say 'creating commit map'
      GitWakaTime.config.load_config_yaml
      @mapper   = Mapper.new(path)

      @timer = Timer.new(@mapper.commits, File.basename(path))
      @commits_with_duration = @timer.process
      @commits_with_duration.each do |commit|
        Log.new commit.to_s
        commit.files.each { |file| Log.new file.to_s }
      end
    end
  end
end
