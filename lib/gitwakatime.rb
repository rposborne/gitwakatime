require 'sequel'
if ENV['thor_env'] != 'test'
  DB = Sequel.connect("sqlite://#{File.join(Dir.home, '.wakatime.sqlite')}")
else
  # Use a in memory db to have a nice clean testing bed.
  DB = Sequel.sqlite
end

Sequel::Model.plugin :json_serializer
DB.use_timestamp_timezones = false

require 'gitwakatime/version'
require 'gitwakatime/durations'
require 'gitwakatime/action'
require 'gitwakatime/commit'
require 'gitwakatime/mapper'
require 'gitwakatime/query'
require 'gitwakatime/timer'
require 'gitwakatime/log'
require 'gitwakatime/commited_file'
require 'gitwakatime/controller'
require 'gitwakatime/cli'

# Silence is golden
module GitWakaTime
  class Configuration
    attr_accessor :api_key, :log_level, :root, :project, :git

    def initialize
      self.api_key = nil
      self.log_level = :info
    end

    def user_name
      GitWakaTime.config.git.config('user.name')
    end

    def load_config_yaml
      yaml = YAML.load_file(File.join(Dir.home, '.wakatime.yml'))
      self.api_key = yaml[:api_key]
      self.log_level = yaml[:log_level]
    end

    def setup_local_db
      DB.create_table? :commits do
        primary_key :id
        String :sha
        String :parent_sha
        String :project
        integer :time_in_seconds, default: 0
        datetime :date
        text :message
        String :author
      end

      DB.create_table? :commited_files do
        primary_key :id
        integer :commit_id
        String :dependent_sha
        DateTime :dependent_date
        integer :time_in_seconds, default: 0
        String :sha
        String :name
        String :project
        index :dependent_sha
        index :sha
      end

      DB.create_table? :actions do
        primary_key :id
        String :uuid
        DateTime :time
        integer :duration, default: 0
        String :file
        String :branch
        String :project
        index :uuid, unique: true
      end
    end
  end

  def self.config
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end
