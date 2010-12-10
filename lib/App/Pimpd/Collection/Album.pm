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

=pod

=head1 NAME

App::Pimpd::Collection::Album - send album related queries to MPD

=head1 EXPORTS

=head2 albums_by_artist()

  my @albums = albums_by_artist('laleh');

In list context, return all albums by artist as L<strings>.

In scalar context, return number of albums by artist.

=cut

sub albums_by_artist {
  my $artist = shift // $mpd->current->artist;

  return wantarray()
    ? sort($mpd->collection->albums_by_artist($artist))
    : scalar($mpd->collection->albums_by_artist($artist))
    ;
}

=head2 songs_on_album()

  my @songs = songs_on_album('Me and Simon', 'Laleh');

In list context, returns a list with Audio::MPD::Common::Item::Song objects.

In scalar context, returns the number of songs found on album.

If called without arguments, use the current album.

If called with a second argument, it's interpreted as the artist name.
This narrows down the result a bit, since a query for C<The Best of> probably
would return more then one result.

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
