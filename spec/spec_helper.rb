# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.before(:all) do
    @wdir = set_file_paths
  end

  config.after(:all) do
    FileUtils.rm_r(File.dirname(@wdir))
  end
end
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
require 'webmock/rspec'

WebMock.disable_net_connect!(allow: 'codeclimate.com')

def set_file_paths
  @test_dir = File.join(File.dirname(__FILE__))
  @wdir_dot = File.expand_path(File.join(@test_dir, 'dummy'))
  @wdir = create_temp_repo(@wdir_dot)
end

def create_temp_repo(clone_path)
  filename = 'git_test' + Time.now.to_i.to_s + rand(300).to_s.rjust(3, '0')
  @tmp_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', filename))
  FileUtils.mkdir_p(@tmp_path)
  FileUtils.cp_r(clone_path, @tmp_path)
  tmp_path = File.join(@tmp_path, 'dummy')
  Dir.chdir(tmp_path) do
    FileUtils.mv('dot_git', '.git')
  end
  tmp_path
end

db_path = File.expand_path File.join(File.dirname(__FILE__), '..', 'test.sqlite')
FileUtils.rm_r(db_path) if File.exist?(db_path)

require 'sequel'
DB = Sequel.connect('sqlite://tmp/test.sqlite')
Sequel::Model.db = DB
DB.create_table :commits do
  primary_key :id
  String :sha
  String :parent_sha
  String :project
  integer :time_in_seconds, default: 0
  datetime :date
  text :message
  String :author
end

DB.create_table :commited_files do
  primary_key :id
  integer :commit_id
  String :dependent_sha
  DateTime :dependent_date
  integer :time_in_seconds, default: 0
  String :sha
  String :name
  String :project
end
