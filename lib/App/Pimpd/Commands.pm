#!/usr/bin/perl
package App::Pimpd::Commands;

require Exporter;
@ISA = 'Exporter';

# play() and stop() defined in Player.pm

our @EXPORT = qw(
  next_track
  previous_track
  clear_playlist
  crop
  crossfade
  toggle_random
  toggle_repeat
  toggle_pause
  random
  repeat
  pause
);

use strict;
use Carp;
use App::Pimpd;

=head3 next_track()

Play the next track in the playlist

=cut

sub next_track {
  $mpd->next;
}

=head3 previous_track()

Play the previous track in the playlist

=cut

sub previous_track {
  $mpd->previous;
}

=head3 clear_playlist()

clear the playlist

=cut

sub clear_playlist {
  $mpd->playlist->clear;
}

=head3 crop()

Remove all songs except for the currently playing song.

=cut

sub crop {
  my $pos = shift;
  if(invalid_playlist_pos($pos)) {
    return 1;
  }
  else {
    $mpd->playlist->crop($pos);
  }
}

=head3 crossfade()

Enable crossfading and set the duration of crossfade between songs. If seconds
is not specified, or if seconds is 0, crossfading is disabled.

=cut

sub crossfade {
  my $sec = shift;
  $mpd->fade($sec);
}

=head3 toggle_random()

Toggle random mode on/off

=cut

sub toggle_random {
  $mpd->random();
}

=head3 toggle_repeat()

Toggle repeat mode on/off

=cut

sub toggle_repeat {
  $mpd->repeat();
}

=head3 random()

Set random mode to 1/0. If no arguments are provided, functions just like
toggle_random().

=cut

sub random {
  $mpd->random(shift);
}

=head3 toggle_pause()

Toggle playback status.

=cut

sub toggle_pause {
  $mpd->pause;
}

=head3 repeat()

Set repeat mode to /10. If no arguments are provided, functions just like
toggle_repeat.

=cut

sub repeat {
  $mpd->repeat(shift);
}

=head3 pause()

Pause/resume playback. If no arguments are provided, functions just like
toggle_pause.

=cut

sub pause {
  $mpd->pause(shift);
}


1;
