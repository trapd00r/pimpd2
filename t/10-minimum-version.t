#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

eval 'use Test::MinimumVersion'; ## no critic
plan skip_all => 'Test::MinimumVersion required' if $@;

all_minimum_version_ok('5.008');





# vim: set ts=2 expandtab sw=2:


