# GitWakaTime

[![Build Status](https://travis-ci.org/rposborne/gitwakatime.svg?branch=master)](https://travis-ci.org/rposborne/gitwakatime)
[![Gem Version](https://badge.fury.io/rb/gitwakatime.svg)](http://badge.fury.io/rb/gitwakatime)
[![Code Climate](https://codeclimate.com/github/rposborne/gitwakatime/badges/gpa.svg)](https://codeclimate.com/github/rposborne/gitwakatime)

GitWakaTime is a mash up between data obtained through "(Wakatime)[https://wakatime.com]" and the data we all create using git.
The principal is to capture a baseline of activity for a task and answer the age old question "How much time did I spend on this?" or "What is the minimum amount I can charge for my time".

This implementation varies form (Wakatime's)[https://wakatime.com/#features] commit feature as it compares time spent on each file, vs comparing the time between commits.  It tends to be significantly more accurate for those who do per line commits. Read more about it (here)[http://burningpony.com/2015/02/that-feature-took-how-long/] 

## Installation

Install the gem:

    $ gem install gitwakatime

Run the setup command: (you will need your wakatime api key)[https://wakatime.com/settings]

    $ gitwakatime init

This creates a .gitwakatime.yml file on the user's home directory ~/.gitwakatime.yml which will contain your api keys and a ~/.gitqakatime.sqlite database to speed things up a bit.

## Usage

Process the current directory for the past 7 days

    $ gitwakatime tally

Process the current directory from a given point  (this will still load all heartbeats data to prevent providing incorrect timing at the start point)

    $ gitwakatime tally -s 2014-02-01

Process the another directory

    $ gitwakatime tally -f ~/some/other/repo

Hard reset of the local cache database, if you are getting odd numbers

    $ gitwakatime reset

## Assumptions

There a currently a few limitations with this model
    
* Merges are free, (no time is attributed a merge).  This is true for most merges but conflict resolution will be attributed to git parent commit of that file for that merge. 

## Output
    Total Recorded time 1 day 9 hrs 13 mins 32 secs
    Total Committed Time 1 day 8 hrs 43 mins 48 secs
    2015-02-04                               Total 2 hrs 59 mins 38 secs
            b1cd1d09c 2015-02-04 00:59:06 -0500 9 mins 4 secs                  Adding fix and test for the query class.
                            d8ca53770            2 mins 51 secs                           lib/gitwakatime/query.rb
                            d8ca53770            6 mins 13 secs                           spec/query_spec.rb
            8e0f0890e 2015-02-04 00:46:52 -0500 26 mins 4 secs                 A new implementation of the split tree file issue,  I think i need a more complex git log to really validate the idea.
                            093f9e4d5            26 mins 4 secs                           lib/gitwakatime/commited_file.rb
            d8ca53770 2015-02-04 00:46:17 -0500 54 mins 13 secs                Improving testing for UTC. Fixing various bugs related to single day comparisons.
                            5471c6c80            6 mins 32 secs                           lib/gitwakatime/query.rb
                            08c7f7005            5 mins 40 secs                           lib/gitwakatime/timer.rb
                            5f3ec243e            27 mins 41 secs                          spec/commited_file_spec.rb
                            95e218d72            4 mins 41 secs                           spec/mapper_spec.rb
                            4949d899a            4 mins 47 secs                           spec/query_spec.rb
                            4949d899a            1 min 49 secs                            spec/spec_helper.rb
                            ea23d7dd7            3 mins 3 secs                            spec/timer_spec.rb
            30415f0a3 2015-02-04 11:54:18 -0500 1 hr 30 mins 17 secs           Cache Heartbeats locally, in sqlite.
                            093f9e4d5            4 mins 19 secs                           lib/gitwakatime.rb
                                                 25 secs                                  lib/gitwakatime/heartbeat.rb
                            caf409884            7 mins 45 secs                           lib/gitwakatime/heartbeats.rb
                            331723757            1 min 39 secs                            lib/gitwakatime/cli.rb
                                                 46 mins 2 secs                           lib/gitwakatime/durations.rb
                            b1cd1d09c            23 mins 50 secs                          lib/gitwakatime/query.rb
                            d8ca53770            3 mins 15 secs                           lib/gitwakatime/timer.rb
                            d8ca53770            1 min 20 secs                            spec/commited_file_spec.rb
                            b1cd1d09c            45 secs                                  spec/query_spec.rb
                            d8ca53770            23 secs                                  spec/spec_helper.rb
                            d8ca53770            34 secs                                  spec/timer_spec.rb
    2015-02-03                               Total 7 hrs 6 mins 19 secs
            5f3ec243e 2015-02-03 23:20:15 -0500 11 mins 55 secs                compare times in utc.
                            34c8f0b99            11 mins 55 secs                          spec/commited_file_spec.rb
            4949d899a 2015-02-03 23:20:02 -0500 24 mins 5 secs                 Reduce log output in testing.
                            b07136e26            18 mins 1 sec                            lib/gitwakatime/log.rb
                            39863a249            4 mins 35 secs                           spec/query_spec.rb

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gitwakatime/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
