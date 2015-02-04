require 'spec_helper'

describe 'description' do
  let (:git) { Git.open(@wdir) }

  before do
    GitWakaTime::Commit.dataset.destroy
    GitWakaTime::Commit.dataset.destroy
  end

  it 'can be created  ' do
    GitWakaTime.config.git = git

    first_commit = GitWakaTime::Commit.find_or_create(
    sha: 'e493d6f2ab2a702fa7f9c168b852a3b44c524f08',
    author: 'Russell Osborne',
    message: 'conflicting commit on blah.',
    project: git.repo.to_s,
    date: '2015-01-29 22:26:05 -0500'
    )

    expect(first_commit.commited_files.first.dependent_sha).to eql('4c1ea35f9a811a0ef79da15ec85f25fce4c446ba')
    expect(first_commit.commited_files.first.dependent_date.utc.to_s).to eql('2015-01-30 03:25:08 UTC')

    second_commit = GitWakaTime::Commit.find_or_create(
       sha: 'd642b3c04c3025655a9c33e32b9d530696dcf7cc',
       author: 'Russell Osborne',
       message: 'conflicting commit on master.',
       project:  git.repo.to_s,
       date: '2015-01-29 22:26:20 -0500'
      )

    expect(second_commit.commited_files.first.dependent_sha).to eql('4c1ea35f9a811a0ef79da15ec85f25fce4c446ba')
    expect(
        GitWakaTime::Commit.find(id: first_commit.id).commited_files.first.dependent_date.utc.to_s
      ).to eql('2015-01-30 03:26:05 UTC')
  end

end
