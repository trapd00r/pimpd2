#!/usr/bin/perl
package App::Pimpd::Playlist::Randomize;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  randomize
  randomize_albums
  random_track_in_playlist
);



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

=head1 NAME

App::Pimpd::Playlist::Randomize

=head1 EXPORTS

=head2 randomize()

Parameters: $integer

Returns:    \@files

=cut

sub randomize {
  my $no_songs = shift // 100;

  my @songs  = shuffle($mpd->collection->all_pathes);
  my @random = (@songs[0 .. $no_songs - 1]);

  return (wantarray()) ? @random : \@random;
}

=head2 randomize_albums()

Parameters: $integer

Returns:    @files

=cut

sub randomize_albums {
  my $no_albums = shift // 10;
  my @albums = shuffle($mpd->collection->all_albums);

  my @songs;
  for(@albums) {
    if($no_albums == 0) {
      last;
    }
    my @songs_on_album = $mpd->collection->songs_from_album($_);
    if(scalar(@songs_on_album) <= 2) {
      next;
    }
    else {
      push(@songs, map { $_->file } @songs_on_album);
      $no_albums--;
    }
  }
  return (wantarray()) ? @songs : scalar(@songs);
}

=head2 random_track_in_playlist()

Returns a random playlist position id.

=cut

sub random_track_in_playlist {
  if(empty_playlist()) {
    print STDERR "Playlist is empty - nothing to play\n";
    return 1;
  }
  my @items = $mpd->playlist->as_items;

  @items = shuffle(@items);

  return $items[0]->pos;
}


1;
