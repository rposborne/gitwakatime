require 'spec_helper'
require 'gitwakatime'
require 'gitwakatime/mapper'

describe 'description' do
  let(:path) { File.expand_path(File.join(File.dirname(__FILE__), '..', '.git', 'modules', 'spec', 'dummy')) }
  it 'can be run on dummy' do
    expect(GitWakaTime::Mapper.new(path).commits.size).to eq 8 # 9ths is lonely
  end
  it 'can be run on dummy' do
    expect(GitWakaTime::Mapper.new(path).commits.last.raw_commit.message).to eq 'created readme'
  end

  it 'maps files dependent commits' do
    expect(GitWakaTime::Mapper.new(path).commits.first.files.first.dependent_commit.sha).to eq 'dcd748bd06b8a0f239d779bee4f1eaf1f4aa500d'
  end

  it 'maps files dependent commits' do
    expect(GitWakaTime::Mapper.new(path).commits.select { |c| c.sha == 'dcd748bd06b8a0f239d779bee4f1eaf1f4aa500d' }.first.files.first.dependent_commit.sha).to eq '2254dd56976b5f32a2289438842e42a35a18ff86'
  end
end
