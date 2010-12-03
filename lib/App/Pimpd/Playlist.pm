#!/usr/bin/perl
package App::Pimpd::Playlist;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  show_playlist
  play_pos_from_playlist
);

use strict;
use Term::ExtendedColor;

use App::Pimpd;
use App::Pimpd::Validate;

sub play_pos_from_playlist {
  my $track_no = shift;

  if(invalid_playlist_pos($track_no)) {
    print STDERR "Playlist index $track_no is invalid\n";
    return 1;
  }
  $mpd->play($track_no);
}

sub show_playlist {
  my @playlist = $mpd->playlist->as_items;

  my $i = 0;
  for my $song(@playlist) {
    my $title  = $song->title  // 'undef';
    my $artist = $song->artist // 'undef';


    my $crnt_title  = $mpd->current->title // undef;
    my $crnt_artist = $mpd->current->artist // undef;
    $title       =~ s/(\w+)/\u\L$1/g;
    $artist      =~ s/(\w+)/\u\L$1/g;
    $crnt_title  =~ s/(\w+)/\u\L$1/g;
    $crnt_artist =~ s/(\w+)/\u\L$1/g;

    if($mpd->current->pos == $i) {
      # bg('red4', $i) will add another 17 chars

      printf("%19s %51.51s |@{[fg('bold', 'x')]}| %-47.47s\n",
        bg('red4', $i), fg('red1', fg('bold',  $artist)), $title);

    }
    else {
      printf("%4d %25.25s | | %-47.47s\n",
        $i, $artist, $title);
    }
    $i++;
  }
}


1;
