# GitWakaTime

[![Build Status](https://travis-ci.org/rposborne/gitwakatime.svg?branch=master)](https://travis-ci.org/rposborne/gitwakatime)
[![Gem Version](https://badge.fury.io/rb/gitwakatime.svg)](http://badge.fury.io/rb/gitwakatime)
[![Code Climate](https://codeclimate.com/github/rposborne/gitwakatime/badges/gpa.svg)](https://codeclimate.com/github/rposborne/gitwakatime)

GitWakaTime is a mashup between data obtained through "wakatime" and the data we all create using git.
The prinicpal is to capture a baseline of activity for a task and answer the age old question "How much time did I spend on this?"



## Installation

Install the gem:

    $ gem install gitwakatime

## Usage

    Creates a .gitwakatime.yml file on the user's home directory ~/.gitwakatime.yml which will contain your api keys
    $ gitwakatime init

    Process the current directory

    $ gitwakatime tally

## Contributing

1. Fork it ( https://github.com/[my-github-username]/gitwakatime/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
