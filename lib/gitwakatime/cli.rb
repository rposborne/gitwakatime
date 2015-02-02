require 'git'
require 'logger'
require 'wakatime'
require 'chronic_duration'
require 'yaml'
require 'thor'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/date_and_time/calculations'
require 'active_support/core_ext/integer/time'
require 'active_support/core_ext/time'

module  GitWakaTime
  # Provides two CLI actions init and tally
  class Cli < Thor
    include Thor::Actions
    desc 'init', 'Setups up Project for using the wakatime API
      it will also add to your git ignore file'
    method_option :file, aliases: '-f', default: '.'

    def init
      api_key = ask('What is your wakatime api key? ( Get it here https://wakatime.com/settings):')
      say('Adding .wakatime.yml to home directory')
      create_file File.join(Dir.home, '.wakatime.yml') do
        YAML.dump(api_key: api_key, last_commit: nil, log_level: :info)
      end
    end

    desc 'tally', 'Produce time spend for each commit and file in each commit'
    method_option :file, aliases: '-f', default: '.'
    method_option :start_on, aliases: '-s', default: nil
    def tally
      path, GitWakaTime.config.root = File.expand_path(options.file)
      date = Date.parse(options.start_on) if options.start_on
      date = 1.month.ago.beginning_of_month unless options.start_on
      GitWakaTime.config.load_config_yaml
      @git_map = Mapper.new(path, start_at: date)
      @actions = Query.new(@git_map.commits, File.basename(path)).get

      @timer   = Timer.new(@git_map.commits, @actions, File.basename(path)).process

      @timer.each do |date, commits|
        Log.new format('%-40s %-40s'.blue,
                       date,
                       "Total #{ChronicDuration.output commits.map(&:time_in_seconds).reduce(&:+)}"
                       )
        commits.each do |commit|
          # Log.new commit.message
          Log.new commit.to_s
          commit.files.each { |file| Log.new file.to_s }
        end
      end
    end
  end
end
