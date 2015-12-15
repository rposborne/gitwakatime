require 'spec_helper'

describe GitWakaTime::TimeRangeEvaluator do
  subject(:subject) do
    described_class.new(
      commits: GitWakaTime::Commit,
      files: GitWakaTime::CommitedFile
    )
  end

  before(:each) do
    GitWakaTime.config.git = Git.open(@wdir)
    GitWakaTime::Mapper.new(start_at: Date.new(2015, 1, 24))
  end

  describe 'start_at' do
    it 'returns the date of the first commit of the current project' do
      expect(subject.start_at.utc).to eql(Time.parse('2015-01-29 21:49:12 -0500').utc)
    end
  end

  describe 'end_at' do
    it 'returns the date of the last commit of the current project' do
      expect(subject.end_at.utc).to eql(Time.parse('2015-01-30 05:19:00 -0500').utc)
    end
  end
end
