require 'gitwakatime/version'
require 'gitwakatime/actions'
require 'gitwakatime/commit'
require 'gitwakatime/mapper'
require 'gitwakatime/query'
require 'gitwakatime/timer'
require 'gitwakatime/log'
require 'gitwakatime/commited_file'
require 'gitwakatime/cli'
# Silence is golden
module GitWakaTime
  class Configuration
    attr_accessor :api_key, :log_level, :root, :project

    def initialize
      self.api_key = nil
      self.log_level = :info
    end

    def load_config_yaml
      yaml = YAML.load_file(File.join(Dir.home, '.wakatime.yml'))
      self.api_key = yaml[:api_key]
      self.log_level = yaml[:log_level]
    end
  end

  def self.config
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end
