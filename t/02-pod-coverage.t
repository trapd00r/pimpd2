#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

unless(exists($ENV{RELEASE_TESTING})) {
  plan skip_all => 'these tests are for release candidate testing';
}

# Test::Pod::Coverage doesn't require a minimum Pod::Coverage version,
# but older versions don't recognize some common documentation styles
my $min_pc = 0.18;
eval "use Pod::Coverage $min_pc"; ## no critic
plan skip_all => "Pod::Coverage $min_pc required for testing POD coverage"
  if $@;
plan skip_all => "Pod::Coverage tests before release"
  if !exists($ENV{RELEASE});

all_pod_coverage_ok();
