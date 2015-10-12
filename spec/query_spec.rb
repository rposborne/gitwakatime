require 'spec_helper'

describe 'description' do

  before(:each) do
    GitWakaTime.config.git = Git.open(@wdir)
    GitWakaTime::Mapper.new(start_at: Date.new(2015, 1, 24))
    @commits = GitWakaTime::Commit
    @files   = GitWakaTime::CommitedFile
    @query = GitWakaTime::Query.new(@commits, @files, File.basename(@wdir))
  end

  before do
    stub_request(:get, 'wakatime.com/api/v1/heartbeats')
    .with(query: hash_including(:date))
    .to_return(body: File.read('./spec/fixtures/heartbeats.json'), status: 200)
  end

  it 'can be run on dummy' do
    heartbeats = @query.get

    expect(heartbeats).to be_a Array
    expect(heartbeats.size).to eq 9 # 10ths is lonely
    expect(heartbeats.last).to be_a GitWakaTime::Heartbeat
    expect(heartbeats.last.branch).to eq 'master'
  end
  it 'produces valid search for api' do

    heartbeats = @query.build_requests

    expect(heartbeats).to be_a Array
    expect(heartbeats.first[:date].to_date).to eq Date.new(2015, 01, 29)

  end
end
