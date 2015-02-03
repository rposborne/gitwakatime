require 'spec_helper'
require 'gitwakatime'

describe 'description' do
  let (:git) { Git.open(@wdir) }
  before(:each) do
    GitWakaTime.config.git = git
    GitWakaTime::Mapper.new
  end

  before do
    stub_request(:get, 'https://wakatime.com/api/v1/actions')
    .with(query: hash_including(:start, :end))
    .to_return(body: File.read('./spec/fixtures/actions.json'), status: 200)
  end

  it 'can be run on dummy' do

    timer = GitWakaTime::Query.new(GitWakaTime::Commit.all, File.basename(@wdir)).get

    expect(timer.size).to eq 6 # 9ths is lonely
    expect(timer).to be_a Array
    expect(timer.last).to be_a Wakatime::Models::Action
    expect(timer.last.branch).to eq 'master'
  end
end
