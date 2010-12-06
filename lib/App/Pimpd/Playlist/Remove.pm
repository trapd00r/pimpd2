#!/usr/bin/perl
package App::Pimpd::Playlist::Remove;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  remove_album_from_playlist
);

use strict;

use App::Pimpd;
use App::Pimpd::Validate;

=head1 NAME

App::Pimpd::Playlist::Remove

=head1 EXPORTS

=head2 remove_album_from_playlist()

Takes a string, possibly regex, matches it against the current playlist albums
and removes the resulting matches.

=cut

sub remove_album_from_playlist {
  my $search_str = shift;

  my @removed;
  for($mpd->playlist->as_items) {
    if($_->album =~ m/$search_str/gi) {
      if(not(invalid_playlist_pos($_->pos))) {
        $mpd->playlist->delete($_->pos);
      }
    }
  }
}



1;
