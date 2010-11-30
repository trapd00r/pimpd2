#!/usr/bin/perl
package App::Pimpd::Playlist::Randomize;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(randomize);

use strict;
use Carp;
use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;

use App::Pimpd;
use App::Pimpd::Validate;
use List::Util 'shuffle';


=head3 randomize()

Return n random tracks in an arrayref.


=cut

sub randomize {
  my $no_songs = shift // 100;

  my @songs  = shuffle($mpd->collection->all_pathes);
  my @random = (@songs[0 .. $no_songs - 1]);

  return \@random;
}


1;
