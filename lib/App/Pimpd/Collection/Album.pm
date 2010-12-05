#!/usr/bin/perl
package App::Pimpd::Collection::Album;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  songs_on_album
  albums_by_artist
  );

use strict;
use App::Pimpd qw($mpd);

=head3 albums_by_artist()

  my @albums = albums_by_artist('laleh');

=cut

sub albums_by_artist {
  my $artist = shift // $mpd->current->artist;

  return wantarray()
    ? $mpd->collection->albums_by_artist($artist)
    : scalar($mpd->collection->albums_by_artist($artist))
    ;
}

=head3 songs_on_album()

Returns a list with Audio::MPD::Common::Item::Song objects in list context.
Returns number of songs in scalar context.

=cut

sub songs_on_album {
  my($album, $artist) = @_;
  #my $album  = shift // $mpd->current->album;
  #my $artist = shift // $mpd->current->artist;

  $album or $album = $mpd->current->album;
  if(!defined($album) or $album eq '') {
    print STDERR "Album tag missing!\n";
    return 1;
  }

  my @tracks;
  if($artist) {
  # We dont want _all_ albums named 'Best Of'.
  @tracks = grep { $_->artist eq $artist }
    $mpd->collection->songs_from_album($album);
  }
  else {
    @tracks = $mpd->collection->songs_from_album($album);
  }

  return (wantarray()) ? @tracks : scalar(@tracks);
}



1;
