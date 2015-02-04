require 'spec_helper'
# * commit a4c26aeb79acb1f012201fe96e4d68e8d17c75d9 (HEAD, origin/master, origin/HEAD, master)
# | Author: rpo <rother@gmail.com>
# | Date:   Sat Jan 31 15:49:07 2015 -0500
# |
# |      I was edited online using git hub's editor
# |
# * commit 570f1df0505ed828656eeaf9411ddd6a6068b095
# | Author: Russell Osborne <rother@gmail.com>
# | Date:   Fri Jan 30 00:19:00 2015 -0500
# |
# |     And one more
# |
# * commit dcd748bd06b8a0f239d779bee4f1eaf1f4aa500d
# | Author: Russell Osborne <rother@gmail.com>
# | Date:   Fri Jan 30 00:01:54 2015 -0500
# |
# |     a final commit on master
# |
# *   commit 57b0d5cdb6da2b2b9ac7e9847716b0c54466d1c6
# |\  Merge: e493d6f d642b3c
# | | Author: Russell Osborne <rother@gmail.com>
# | | Date:   Thu Jan 29 22:27:26 2015 -0500
# | |
# | |     Merge branch 'dev'
# | |
# | * commit d642b3c04c3025655a9c33e32b9d530696dcf7cc
# | | Author: Russell Osborne <rother@gmail.com>
# | | Date:   Thu Jan 29 22:26:05 2015 -0500
# | |
# | |     another commit on dev.
# | |
# * | commit e493d6f2ab2a702fa7f9c168b852a3b44c524f08
# |/  Author: Russell Osborne <rother@gmail.com>
# |   Date:   Thu Jan 29 22:26:20 2015 -0500 or 1422570380
# |
# |       conflicting commit on master.
# |
# * commit 4c1ea35f9a811a0ef79da15ec85f25fce4c446ba
# | Author: Russell Osborne <rother@gmail.com>
# | Date:   Thu Jan 29 22:25:08 2015 -0500 or 1422570308
# |
# |     commit on dev branch
# |
# * commit 2254dd56976b5f32a2289438842e42a35a18ff86
# | Author: Russell Osborne <rother@gmail.com>
# | Date:   Thu Jan 29 21:49:31 2015 -0500
# |
# |     testing
# |
# * commit 052ff8c0e8c7cd39880d1536f4e27cc554e698f6
#   Author: Russell Osborne <rother@gmail.com>
#   Date:   Thu Jan 29 21:49:12 2015 -0500

#       created readme
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
    date: Time.at(1_422_570_380)
    )

    expect(first_commit.commited_files.first.dependent_sha).to eql('4c1ea35f9a811a0ef79da15ec85f25fce4c446ba')
    expect(first_commit.commited_files.first.dependent_date.utc.to_s).to eql('2015-01-30 03:25:08 UTC')

    second_commit = GitWakaTime::Commit.find_or_create(
       sha: 'd642b3c04c3025655a9c33e32b9d530696dcf7cc',
       author: 'Russell Osborne',
       message: 'conflicting commit on master.',
       project:  git.repo.to_s,
       date: 'Thu Jan 29 22:26:05 2015 -0500'
      )

    expect(second_commit.commited_files.first.dependent_sha).to eql('4c1ea35f9a811a0ef79da15ec85f25fce4c446ba')
    expect(
        GitWakaTime::Commit.find(id: first_commit.id).commited_files.first.dependent_date.utc.to_s
      ).to eql('2015-01-30 03:25:08 UTC')
    expect(second_commit.commited_files.first.dependent_date.utc.to_s).to eql(Time.at(1422570380).utc.to_s)
  end

end
