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
    GitWakaTime::Mapper.new
    actions = GitWakaTime::Query.new(GitWakaTime::Commit.all, File.basename(@wdir)).get
    timer = GitWakaTime::Timer.new(GitWakaTime::Commit.all, actions, File.basename(@wdir)).process
    expect(timer.size).to eq 2
  end
end
