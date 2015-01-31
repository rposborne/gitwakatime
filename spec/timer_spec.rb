require 'spec_helper'
require 'gitwakatime'

describe 'description' do
  let (:map) { GitWakaTime::Mapper.new(@wdir) }

  before do
    stub_request(:get, 'https://wakatime.com/api/v1/actions')
    .with(query: hash_including(:start, :end))
    .to_return(body: File.read('./spec/fixtures/actions.json'), status: 200)
  end

  it 'can be run on dummy' do
    actions = GitWakaTime::Query.new(map.commits, File.basename(@wdir)).get
    timer = GitWakaTime::Timer.new(map.commits, actions, File.basename(@wdir)).process
    expect(timer.size).to eq 2
  end
end
