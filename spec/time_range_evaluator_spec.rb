require 'spec_helper'

describe GitWakaTime::TimeRangeEvaluator do
  subject(:subject) do
    described_class.new(
      commits: GitWakaTime::Commit,
      files: GitWakaTime::CommitedFile
    )
  end

  it 'returns start range' do
    expect(subject.start_at).to be_within(0.1).of(Time.now)
  end

  it 'returns end range' do
    expect(subject.start_at).to be_within(0.1).of(Time.now)
  end
end
