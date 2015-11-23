require 'spec_helper'

describe 'description' do
  let(:git) { Git.open(@wdir) }
  let(:heartbeat) { double(:heartbeat, sum: 1) }
  let(:heartbeats) { double(:heartbeats, grep: [heartbeat, heartbeat]) }

  before do
    stub_request(:get, /.*wakatime.com\/api\/v1\/heartbeats/)
      .with(query: hash_including(:date))
      .to_return(body: File.read('./spec/fixtures/heartbeats.json'), status: 200)

    # Prevent any callbacks to git.
    # TODO: Refactor callbacks.
    GitWakaTime.config.git = nil
  end

  it 'can be run on dummy with no heartbeats' do
    timer = GitWakaTime::Timer.new(
      GitWakaTime::Commit.all, GitWakaTime::Heartbeat
    ).process

    # # UTC breaks heartbeats of 1 day
    # expect(timer.size).to eq 1
    # With 7 relevant commits
    expect(timer).to eq Hash.new
  end

  it 'can be run on dummy with no heartbeats' do
    c1 = GitWakaTime::Commit.create(sha: 'e493d6f2ab2a702fa7f9c168b852a3b44c524f08', parent_sha: '4c1ea35f9a811a0ef79da15ec85f25fce4c446ba', project: 'dummy', time_in_seconds: 0, date: Time.parse('2015-01-30 03:26:12 UTC'), message: 'conflicting commit on master.', author: 'Russell Osborne')
    c2 = GitWakaTime::Commit.create(sha: 'd642b3c04c3025655a9c33e32b9d530696dcf7cc', parent_sha: '4c1ea35f9a811a0ef79da15ec85f25fce4c446ba', project: 'dummy', time_in_seconds: 0, date: Time.parse('2015-01-30 03:26:05 UTC'), message: 'another commit on dev.', author: 'Russell Osborne')
    GitWakaTime::CommitedFile.create(commit_id: c1.id, dependent_sha: '4c1ea35f9a811a0ef79da15ec85f25fce4c446ba', dependent_date: Time.parse('2015-01-30 01:00:00 UTC'), time_in_seconds: 0, sha: 'd642b3c04c3025655a9c33e32b9d530696dcf7cc', name: '/dummy/spec/commit_spec.rb', entity: nil, project: 'dummy')
    GitWakaTime::CommitedFile.create(commit_id: c2.id, dependent_sha: '4c1ea35f9a811a0ef79da15ec85f25fce4c446ba', dependent_date: Time.parse('2015-01-30 02:00:00 UTC'), time_in_seconds: 0, sha: 'd642b3c04c3025655a9c33e32b9d530696dcf7cc', name: '/dummy/lib/dummy/timer.rb', entity: nil, project: 'dummy')
    GitWakaTime::Heartbeat.create(time: Time.parse('2015-01-30 02:33:00 UTC'), duration: 500, entity: '/dummy/spec/commit_spec.rb', type: 'file', branch: 'master', project: 'dummy')
    GitWakaTime::Heartbeat.create(time: Time.parse('2015-01-30 02:31:54 UTC'), duration: 333, entity: '/dummy/lib/dummy/timer.rb', type: 'file', branch: 'master', project: 'dummy')

    timer = GitWakaTime::Timer.new(
      GitWakaTime::Commit.all, GitWakaTime::Heartbeat
    ).process

    # One hash key per day
    expect(timer.size).to eq 1
    expect(timer[Date.new(2015, 1, 30)]).to be_a(Array)
    expect(timer[Date.new(2015, 1, 30)].map(&:time_in_seconds).compact.reduce(&:+)).to eq(500 + 333)
  end
end
