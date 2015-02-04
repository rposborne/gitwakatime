# GitWakaTime

[![Build Status](https://travis-ci.org/rposborne/gitwakatime.svg?branch=master)](https://travis-ci.org/rposborne/gitwakatime)
[![Gem Version](https://badge.fury.io/rb/gitwakatime.svg)](http://badge.fury.io/rb/gitwakatime)
[![Code Climate](https://codeclimate.com/github/rposborne/gitwakatime/badges/gpa.svg)](https://codeclimate.com/github/rposborne/gitwakatime)

GitWakaTime is a mash up between data obtained through "wakatime" and the data we all create using git.
The principal is to capture a baseline of activity for a task and answer the age old question "How much time did I spend on this?" or "What is the minimum amount I can charge for my time"

## Installation

Install the gem:

    $ gem install gitwakatime

    Run the setup command: (you will need your wakatime api key). Creates a .gitwakatime.yml file on the user's home directory ~/.gitwakatime.yml which will contain your api keys

    $ gitwakatime init


## Usage
    Process the current directory

    $ gitwakatime tally

    Hard reset of the local cache database

    $ gitwakatime reset


## Output
    Total Recorded time 21 hrs 59 mins 59 secs
    Total Commited Time 18 hrs 50 mins 53 secs
    2015-01-30                               Total 2 hrs 40 mins 22 secs
            5f938e6a8 2015-01-30 00:28:07 -0500 1 hr 6 mins 25 secs            Adding dependent file tests.
                     658ae589e            13 mins 11 secs                          lib/gitwakatime/timer.rb
                     a42b7bc18            53 mins 14 secs                          spec/commit_spec.rb
            34014889b 2015-01-30 00:27:35 -0500 1 hr 33 mins 57 secs           Renaming Parent commit, expose raw commit, and fixed dependent commit time lookup.
                     658ae589e            1 hr 43 secs                             lib/gitwakatime/commit.rb
                     658ae589e            33 mins 14 secs                          lib/gitwakatime/commited_file.rb
    2014-11-14                               Total 6 hrs 9 mins 15 secs
            658ae589e 2014-11-14 00:05:45 -0500 6 hrs 9 mins 15 secs           Smoothly breaks apart request to multiple queries to wakatime.
                     f97f77f0b            13 mins 49 secs                          README.md
                     c983f9fb4                                                     Rakefile
                     3575ba3bb            13 mins 59 secs                          gitwakatime.gemspec
                     b0accb9f0            25 mins 11 secs                          lib/gitwakatime/actions.rb
                     3575ba3bb            20 mins 13 secs                          lib/gitwakatime/cli.rb
                     070a759c8            24 mins 31 secs                          lib/gitwakatime/commit.rb
                     25701d955            12 mins 38 secs                          lib/gitwakatime/commited_file.rb
                     fe60ad723            1 hr 56 mins 24 secs                     lib/gitwakatime/mapper.rb
                     83b90c361            2 hrs 22 mins 30 secs                    lib/gitwakatime/timer.rb

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gitwakatime/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
