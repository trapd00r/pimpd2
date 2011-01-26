package App::Pimpd::Commands;
use strict;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
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
}

use App::Pimpd;

sub next_track {
  $mpd->next;
  return;
}

sub previous_track {
  $mpd->prev;
  return;
}

sub clear_playlist {
  $mpd->playlist->clear;
  return;
}

sub crop {
  my $pos = shift;
  if(invalid_playlist_pos($pos)) {
    return 1;
  }
  else {
    $mpd->playlist->crop($pos);
  }
  return;
}

sub crossfade {
  my $sec = shift;
  $mpd->fade($sec);
  return;
}

sub toggle_random {
  $mpd->random();
  return;
}

sub toggle_repeat {
  $mpd->repeat();
  return;
}

sub random {
  $mpd->random(shift);
  return;
}

sub toggle_pause {
  $mpd->pause;
  return;
}


sub repeat {
  $mpd->repeat(shift);
  return;
}

sub pause {
  $mpd->pause(shift);
  return;
}


1;

__END__

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

=over

=item next_track()

Play the next track in the current playlist.

=item previous_track()

Play the previous track in the current playlist.

=item clear_playlist()

Clear the current playlist.

=item crop()

Remove all tracks but the currently playing in the current playlist.

=item crossfade()

Parameters: $seconds

Enable crossfading and set the duration of crossfade between songs. If seconds
is omitted, or if seconds is zero, crossfading is disabled.

=item toggle_random()

Toggle random mode on/off

=item toggle_repeat()

Toggle repeat mode on/off

=item toggle_pause()

Toggle playback status

=item random()

Parameters: $integer

Set/unset random mode. Non-zero sets random mode on, zero sets random mode off.

=item repeat()

Set/unset repeat mode. Non-zero sets repeat mode on, zero sets repeat mode off.

=item pause()

Set playback status. Non-zero resumes playback, zero pauses.
Called with zero arguments, functions just like B<toggle_pause()>.

=back

=head1 SEE ALSO

App::Pimpd

=head1 AUTHOR

  Magnus Woldrich
  CPAN ID: WOLDRICH
  magnus@trapd00r.se
  http://japh.se

=head1 COPYRIGHT

Copyright (C) 2010, 2011 Magnus Woldrich. All right reserved.
This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
