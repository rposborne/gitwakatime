require 'spec_helper'

describe 'description' do
  let(:git) { Git.open(@wdir) }

  before do
    stub_request(:get, 'https://wakatime.com/api/v1/heartbeats')
    .with(query: hash_including(:start, :end))
    .to_return(body: File.read('./spec/fixtures/heartbeats.json'), status: 200)
  end

  it 'can be run on dummy' do
    GitWakaTime.config.git = git
    GitWakaTime::Mapper.new(start_at: Date.new(2015, 1, 24))
    heartbeats = GitWakaTime::Query.new(
      GitWakaTime::Commit, GitWakaTime::CommitedFile, File.basename(@wdir)
    ).get
    timer = GitWakaTime::Timer.new(
      GitWakaTime::Commit.all, heartbeats, File.basename(@wdir)
    ).process

    # # UTC breaks heartbeats of 1 day
    # expect(timer.size).to eq 1
    # With 7 relevant commits
    expect(timer[timer.keys.first].size).to eq 7
    expect(
      timer[Date.new(2015, 1, 30)].map(&:time_in_seconds).compact.reduce(&:+)
    ).to eql(201)
  end
end
