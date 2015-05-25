[![Gem Version](https://badge.fury.io/rb/redis-hl.svg)](http://badge.fury.io/rb/redis-hl) [![Build Status](https://travis-ci.org/unleashed/redis-hl.svg?branch=master)](https://travis-ci.org/unleashed/redis-hl) [![Code Climate](https://codeclimate.com/github/unleashed/redis-hl/badges/gpa.svg)](https://codeclimate.com/github/unleashed/redis-hl) [![Test Coverage](https://codeclimate.com/github/unleashed/redis-hl/badges/coverage.svg)](https://codeclimate.com/github/unleashed/redis-hl)

# The Redis-HL gem

This is the Redis HL (for High Level) gem.

It is a wrapper of the Redis gem for working with Redis with higher level Ruby
objects, abstracting Redis structures and making them work like Enumerables.

## Usage

WIP

## Generating the gem

Both bundler and rspec are required to build the gem:

    $ gem install bundler rspec

Run rake -T to see available tasks. The gem can be built with:

    $ rake build

Or, if you want to make sure everything works correctly:

    $ bundle exec rake build

## Installation

After generating the gem, install it using:

    $ gem install pkg/redis-hl-*.gem
