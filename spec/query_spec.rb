require 'spec_helper'

describe 'description' do

  before(:each) do
    GitWakaTime.config.git = Git.open(@wdir)
    GitWakaTime::Mapper.new(start_at: Date.new(2015, 1, 24))
  end

  before do
    stub_request(:get, 'https://wakatime.com/api/v1/actions')
    .with(query: hash_including(:start, :end))
    .to_return(body: File.read('./spec/fixtures/actions.json'), status: 200)
  end

  it 'can be run on dummy' do

    actions = GitWakaTime::Query.new(GitWakaTime::Commit.all, File.basename(@wdir)).get

    expect(actions).to be_a Array
    expect(actions.size).to eq 6 # 9ths is lonely
    expect(actions.last).to be_a GitWakaTime::Action
    expect(actions.last.branch).to eq 'master'
  end
  it 'produces valid search for api' do
    actions = GitWakaTime::Query.new(GitWakaTime::Commit.all, File.basename(@wdir)).time_params

    expect(actions).to be_a Array
    expect(actions.first[:start].to_date).to eq Date.new(2015, 01, 30)
    expect(actions.first[:end].to_date).to eq Date.new(2015, 02, 14)
  end
end
