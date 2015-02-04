require 'spec_helper'

describe 'description' do
  let (:git) { Git.open(@wdir) }

  before do
    stub_request(:get, 'https://wakatime.com/api/v1/actions')
    .with(query: hash_including(:start, :end))
    .to_return(body: File.read('./spec/fixtures/actions.json'), status: 200)
  end

  it 'can be run on dummy' do
    GitWakaTime.config.git = git
    GitWakaTime::Mapper.new(start_at: Date.new(2015, 1, 24))
    actions = GitWakaTime::Query.new(GitWakaTime::Commit.all, File.basename(@wdir)).get
    timer = GitWakaTime::Timer.new(GitWakaTime::Commit.all, actions, File.basename(@wdir)).process

    # # UTC breaks actions of 1 day
    # expect(timer.size).to eq 1
    # With 8 relevant commits
    expect(timer[timer.keys.first].size).to eq 8
  end
end
