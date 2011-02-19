#!/usr/bin/perl
# test for correct line endings

use strict;
use warnings;
use Test::More;

eval 'use Test::EOL';    ## no critic
plan skip_all => 'Test::EOL required' if $@;

all_perl_files_ok( { trailing_whitespace => 1 }, qw/ lib t / );
