require 'spec_helper'

describe GitWakaTime::Cli do
  before do
    stub_request(:get, /wakatime\.com/)
    .with(query: hash_including(:date))
    .to_return(body: File.read('./spec/fixtures/heartbeats.json'), status: 200)
  end
  it 'should be able to be called' do
    ARGV.replace %w[tally --start_on 2012-01-01 --file] << @wdir.to_s
    expect { GitWakaTime::Cli.start }.to output.to_stdout
    # puts GitWakaTime::Cli.start('tally', "--file #{@wdir.to_s}")
  end
end
