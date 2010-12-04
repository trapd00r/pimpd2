#!/usr/bin/perl
package App::Pimpd::Collection::Album;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  songs_on_album
  );

use strict;
use App::Pimpd qw($mpd);
use Carp 'confess';
use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;


=head3 songs_on_album()

If no argument supplied, use the current album playing.

Returns a list with Audio::MPD::Common::Item::Song objects in list context.
Returns number of songs in scalar context.

=cut

sub songs_on_album {
  my $album = shift // $mpd->current->album;
  my $artist = $mpd->current->artist;

  if(!defined($album) or $album eq '') {
    print STDERR "Album tag missing!\n";
    return 1;
  }

  # We dont want _all_ albums named 'Best Of'.
  my @tracks = grep { $_->artist eq $artist }
    $mpd->collection->songs_from_album($album);


  return (wantarray()) ? @tracks : scalar(@tracks);
}



1;
