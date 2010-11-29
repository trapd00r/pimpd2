#!/usr/bin/perl
package App::Pimpd::Playlist::Add;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(add_to_playlist);

use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;

use App::Pimpd;


sub add_to_playlist {
  my $song = shift;

  my @songs;
  if(ref($song) eq 'ARRAY') {
    push(@songs, @{$song});
    undef($song);
  }
  else {
    return "This is a scalar: $song\n";
  }
  return "Arrayref I got: @songs";
}


1;
