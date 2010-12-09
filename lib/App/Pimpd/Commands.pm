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

=pod

=head1 NAME

App::Pimpd::Commands - basic commands controlling playback

=head1 EXPORTS

=head2 next_track()

Play the next track in the playlist

=cut

sub next_track {
  $mpd->next;
}

=head2 previous_track()

Play the previous track in the playlist

=cut

sub previous_track {
  $mpd->previous;
}

=head2 clear_playlist()

clear the playlist

=cut

sub clear_playlist {
  $mpd->playlist->clear;
}

=head2 crop()

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

=head2 crossfade()

Enable crossfading and set the duration of crossfade between songs. If seconds
is not specified, or if seconds is 0, crossfading is disabled.

=cut

sub crossfade {
  my $sec = shift;
  $mpd->fade($sec);
}

=head2 toggle_random()

Toggle random mode on/off

=cut

sub toggle_random {
  $mpd->random();
}

=head2 toggle_repeat()

Toggle repeat mode on/off

=cut

sub toggle_repeat {
  $mpd->repeat();
}

=head2 random()

Set random mode to 1/0. If no arguments are provided, functions just like
toggle_random().

=cut

sub random {
  $mpd->random(shift);
}

=head2 toggle_pause()

Toggle playback status.

=cut

sub toggle_pause {
  $mpd->pause;
}

=head2 repeat()

Set repeat mode to /10. If no arguments are provided, functions just like
toggle_repeat.

=cut

sub repeat {
  $mpd->repeat(shift);
}

=head2 pause()

Pause/resume playback. If no arguments are provided, functions just like
toggle_pause.

=cut

sub pause {
  $mpd->pause(shift);
}

=pod

=head1 NAME

App::Pimpd::Commands - Package exporting usual commands

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Commands;

    if( ... ) {
      next_track();
    }
    else {
      previous_track();
    }

=head1 DESCRIPTION

B<App::Pimpd::Commands> exports functions dealing with usual commands

=head1 EXPORTS

=head2 next_track()

Play the next track in the current playlist.

=head2 previous_track()

Play the previous track in the current playlist.

=head2 clear_playlist()

Clear the current playlist.

=head2 crop()

Remove all tracks but the currently playing in the current playlist.

=head2 crossfade()

Parameters: $seconds

Enable crossfading and set the duration of crossfade between songs. If seconds
is omitted, or if seconds is zero, crossfading is disabled.

=head2 toggle_random()

Toggle random mode on/off

=head2 toggle_repeat()

Toggle repeat mode on/off

=head2 toggle_pause()

Toggle playback status

=head2 random()

Parameters: $integer

Set/unset random mode. Non-zero sets random mode on, zero sets random mode off.

=head2 repeat()

Set/unset repeat mode. Non-zero sets repeat mode on, zero sets repeat mode off.

=head2 pause()

Set playback status. Non-zero resumes playback, zero pauses.
Called with zero arguments, functions just like B<toggle_pause()>.

=head1 SEE ALSO

App::Pimpd

=head1 AUTHOR

  Magnus Woldrich
  CPAN ID: WOLDRICH
  magnus@trapd00r.se
  http://japh.se

=head1 COPYRIGHT

Copyright (C) 2010 Magnus Woldrich. All right reserved.
This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
