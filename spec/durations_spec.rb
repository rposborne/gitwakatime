require 'spec_helper'

describe GitWakaTime::Durations do
  subject(:subject) { described_class.new({ date: Time.now }) }
  describe 'caching'
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
