require 'spec_helper'
require 'gitwakatime'

describe 'description' do
  let(:path) { File.join(File.dirname(__FILE__), 'dummy') }
  let (:map) { GitWakaTime::Mapper.new(path) }

  before do
    stub_request(:get, 'https://wakatime.com/api/v1/actions')
    .with(query: hash_including(:start, :end))
    .to_return(body: File.read('./spec/fixtures/actions.json'), status: 200)
  end

  it 'can be run on dummy' do

    timer = GitWakaTime::Query.new(map.commits, File.basename(path)).get

    expect(timer.size).to eq 6 # 9ths is lonely
    expect(timer).to be_a Array
    expect(timer.last).to be_a Wakatime::Models::Action
    expect(timer.last.branch).to eq 'master'
  end
end
