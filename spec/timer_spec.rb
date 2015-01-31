require 'spec_helper'
require 'gitwakatime'

describe 'description' do
  let(:path) { File.expand_path(File.join(File.dirname(__FILE__), '..', '.git', 'modules', 'spec', 'dummy')) }
  let (:map) { GitWakaTime::Mapper.new(path) }

  before do
    stub_request(:get, 'https://wakatime.com/api/v1/actions')
    .with(query: hash_including(:start, :end))
    .to_return(body: File.read('./spec/fixtures/actions.json'), status: 200)
  end

  it 'can be run on dummy' do
    actions = GitWakaTime::Query.new(map.commits, File.basename(path)).get
    timer = GitWakaTime::Timer.new(map.commits, actions, File.basename(path)).process
    expect(timer.size).to eq 2
  end
end
