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
