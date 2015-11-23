require 'spec_helper'

describe 'Query spec' do
  before(:each) do
    GitWakaTime.config.git = Git.open(@wdir)
    GitWakaTime::Mapper.new(start_at: Date.new(2015, 1, 24))

    @time_range = GitWakaTime::TimeRangeEvaluator.new(
      commits: GitWakaTime::Commit,
      files: GitWakaTime::CommitedFile,
      project: File.basename(@wdir)
    )

    @query = GitWakaTime::Query.new(@time_range)
  end

  before do
    stub_request(:get, /.*wakatime.com\/api\/v1\/heartbeats/)
      .with(query: hash_including(:date))
      .to_return(body: File.read('./spec/fixtures/heartbeats.json'), status: 200)
  end

  it 'will return an array of heartbeats' do
    heartbeats = @query.call

    expect(heartbeats).to be_a Array
    expect(heartbeats.size).to eq 9 # 10ths is lonely
    expect(heartbeats.last).to be_a GitWakaTime::Heartbeat
    expect(heartbeats.last.branch).to eq 'master'
  end
end
