#!/usr/bin/env ruby

require 'git'
require 'logger'
require 'wakatime'
require 'ap'
require 'colorize'
require_relative '../lib/git-time.rb'

def print_message(msg , color = nil)
  if color.nil?
    ap msg
  else
    puts msg.send(color)
  end
end

def commit_to_hash(commit)
  { time: 0,
    sha1: commit.sha,
    commited_at: commit.date,
    message: commit.message }
end

root_path = File.expand_path(ARGV[0] || '../')
current_project = File.basename(root_path)
g = Git.open(root_path)
print_message(current_project, :green)
start_date = '1 weeks ago'
logs = g.log(100).since(start_date)
@change_logs = {}

logs.each do |commit|

  if commit.parent
    commit.diff_parent.stats[:files].keys.each do |file|
      begin
        dependent_commit = g.log(100).object(file)[1]
      rescue Git::GitExecuteError
        dependent_commit = nil
      end

      commit_hash = commit_to_hash(commit)

      if dependent_commit
        commit_hash[:dependent_commit] = commit_to_hash(dependent_commit)
      else
        commit_hash[:dependent_commit] = nil
      end

      file = File.join(root_path, file)
      @change_logs[file] ||= { commits: [], actions: [] }
      @change_logs[file][:commits] << commit_hash
    end

  end
end
ap @change_logs

# @session = Wakatime::Session.new({
#     api_key: "1ce219c6-73ec-4ed7-be64-11fbfcc8c9d7"
# })
# @client = Wakatime::Client.new(@session)
# @actions =  @client.actions(:project => "git-log")
# .select{|action| action.project == current_project}

# @actions_by_file = @actions.group_by(&:file)

# @actions_by_file.each do |file, actions|
#   @change_logs[file] ||= {commits: [], actions: []}
#   @change_logs[file][:actions] = actions
# end
# @commits = {}

# @change_logs.each do |file, events|
#   puts g.gblob(file).log
#   events[:commits].each do |commit|
#     relevant_actions = events[:actions]
# .select{|action| action.time <= commit[:commited_at].to_i}
#     unless relevant_actions.empty?
#       puts relevant_actions.first
#     start_at = Time.at(relevant_actions.collect(&:time).min)
#     end_at = Time.at(relevant_actions.collect(&:time).max)
#     @commits[commit[:sha1]] ||= commit
#     @commits[commit[:sha1]][:time] += (end_at - start_at)
#   end
#   end
# end

# @commits.each do |sha1, commit|
#   puts commit.inspect
#   puts "#{sha1} took #{commit[:time] / 60 / 60}h"
# end
