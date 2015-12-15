require 'spec_helper'

describe GitWakaTime::Query do
  before(:each) do
    GitWakaTime.config.git = Git.open(@wdir)
    GitWakaTime::Mapper.new(start_at: Date.new(2015, 1, 24))
  end

  let(:start_at) { Date.new(2015, 1, 24) }
  let(:end_at) { Date.new(2015, 2, 24) }

  let(:time_range) { double('time_range', start_at: start_at, end_at: end_at) }

  before do
    stub_request(:get, /.*wakatime.com\/api\/v1\/users\/current\/heartbeats/)
      .with(query: hash_including(:date))
      .to_return(body: File.read('./spec/fixtures/heartbeats.json'), status: 200)
  end

  subject(:subject) { described_class.new(@time_range, File.basename(@wdir)) }

  it 'will return an array of heartbeats' do
    heartbeats = subject.call

    expect(heartbeats).to be_a Array
    expect(heartbeats.size).to eq 9 # 10ths is lonely
    expect(heartbeats.last).to be_a GitWakaTime::Heartbeat
    expect(heartbeats.last.branch).to eq 'master'
  end

  describe 'caching' do
    it 'when db empty be falsey' do
      expect(subject.cached?).to eq(false)
    end

    describe 'when heartbeats present' do
      before do
        expect(GitWakaTime::Heartbeat).to receive(:max).with(:time)
          .and_return(Time.now.to_s)
      end
      it 'when db empty be falsey' do
        expect(subject.cached?).to eq(false)
      end
    end
  end
end
