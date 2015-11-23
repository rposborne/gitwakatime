require 'spec_helper'

describe GitWakaTime::RequestBuilder do
  subject(:subject) { described_class.new(3.days.ago, Time.now).call }

  it 'returns a array of hashes' do
    expect(subject).to be_a(Array)
    expect(subject.first).to be_a(Hash)
  end

  it 'has a hash per day' do
    expect(subject.size).to eq(4)
  end

  it 'has a first hash will be for 3 days ago' do
    expect(subject.first).to eq(
      date: 3.days.ago.to_date,
      show: 'file,branch,project,time,id'
    )
  end
end
