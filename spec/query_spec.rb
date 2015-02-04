require 'spec_helper'

describe 'description' do
  let (:git) { Git.open(@wdir) }
  before(:each) do
    GitWakaTime.config.git = git

  end

  before do
    stub_request(:get, 'https://wakatime.com/api/v1/actions')
    .with(query: hash_including(:start, :end))
    .to_return(body: File.read('./spec/fixtures/actions.json'), status: 200)
  end

  it 'can be run on dummy' do
    GitWakaTime::Mapper.new(start_at: Date.new(2015, 1, 24))

    actions = GitWakaTime::Query.new(GitWakaTime::Commit.all, File.basename(@wdir)).get

    expect(actions).to be_a Array
    expect(actions.size).to eq 6 # 9ths is lonely
    expect(actions.last).to be_a Wakatime::Models::Action
    expect(actions.last.branch).to eq 'master'
  end
end
