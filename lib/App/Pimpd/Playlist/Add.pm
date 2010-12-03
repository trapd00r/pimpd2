#!/usr/bin/perl
package App::Pimpd::Playlist::Add;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(add_to_playlist);

use strict;
use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;

use App::Pimpd;
use App::Pimpd::Validate;


=head3 add_to_playlist()

  add_to_playlist($file);
  add_to_playlist(\@files);

Add file to the current playlist.

File must be in the MPD format, without the music_directory prefix.

=cut

sub add_to_playlist {
  my @songs = @_;

  if(ref($songs[0] eq 'ARRAY')) {
    push(@songs, @{$songs[0]});
    shift(@songs);
  }
  chomp(@songs);

  $mpd->playlist->add(@songs);
  return 0;
}


1;
