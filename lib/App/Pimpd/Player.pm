#!/usr/bin/perl
package App::Pimpd::Player;

use vars qw($VERSION);
$VERSION = 0.10;

require Exporter;
@ISA = 'Exporter';

#FIXME
our @EXPORT = qw(
  play
  stop
  player_init
  player_daemonize
  player_destruct
);

use strict;
use Carp;
use Term::ExtendedColor;

use App::Pimpd;

# NOTE To config
my $pidfile_pimpd   = '/tmp/pimpd2.pid';
my $pidfile_player  = '/tmp/pimpd2-player.pid';
my $player_tmp_log  = '/tmp/pimpd2.log';

my $cmdline = player_cmdline();

sub player_init {
  my $fails = 0;

  # Not playing!
  if(! -e $player_tmp_log) {
    player_daemonize($player_tmp_log);
    exec($cmdline);
  }
  else {
    open(my $fh, '<', $player_tmp_log);
    while(<$fh>) {
      if(/Exiting\.\.\. \(End of file\)/) {
        $fails++;
        # fulhack. Time::HiRes
        select(undef, undef, undef, 0.50);
        # 10s of trying
        if($fails == 20) {
          last;
        }
      }
    }
    close($fh);
  }
  if($fails == 20) {
    unlink($player_tmp_log);
    #player_destruct();
    return 0;
  }
  else {
    player_daemonize($player_tmp_log);
    exec($cmdline);
  }
  return 0;
}


sub player_daemonize {
  my $daemon_log = shift // '/dev/null';
  use POSIX 'setsid';
  my $PID = fork();
  exit(0) if($PID); #parent
  exit(1) if(!defined($PID)); # out of resources

  setsid();
  $PID = fork();
  exit(1) if(!defined($PID));

  if($PID) { # parent
    open(my $fh, '>', $pidfile_pimpd) or die($!);
    print $fh $$;
    close($fh);

    waitpid($PID, 0);
    #unlink($pidfile); # remove the lock when child have died

    # Child have died/returned.
    # This means that MPD is in a state where it's not sending any data
    # We try to reconnect 15 times with a delay, and if the stream is still
    # down, we exit. See player_init()

    player_init();
    exit(0);
  }
  elsif($PID == 0) { # child
    open(my $fh, '>', "$pidfile_player") or die("pidfile $pidfile_player: $!");
    print $fh $$;
    close($fh);
    open(STDOUT, '>>',  $daemon_log);
    open(STDERR, '>', '/dev/null');
    open(STDIN,  '<', '/dev/null');
  }
  return 0;
}

sub play {
  player_destruct(); # FIXME
  $mpd->play;
  player_init();

  #if(player_init() == 1) {
  #  $mpd->play;
  #}
}

sub stop {
  $mpd->stop;
  #unlink($player_tmp_log);
  player_destruct();
}

sub player_destruct {
  open(my $fh, '<', $pidfile_pimpd) or return 1; # for now
  my $pimpd_player = <$fh>;
  close($fh);

  if(kill(9, $pimpd_player)) {
    unlink($player_tmp_log);
    #printf("%s %s\n", fg('bold', $pimpd_player), 'terminated');
  }

  open(my $fh, '<', $pidfile_player) or die($!);
  my $pimpd_target = <$fh>;
  close($fh);

  if(kill(9, $pimpd_target)) {
    #printf("%s %s\n", fg('bold', $pimpd_target, 'terminated'));
  }

  if(kill(9, $pimpd_target+1)) {
    #printf("%s %s\n", fg('bold', $pimpd_target + 1), 'terminated');
  }
  return 0;
}

=pod

=head1 NAME

App::Pimpd::Player - Package exporting functions that helps with local playback

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Player;

    if($play_music) {
      play();
    }
    elsif($time_to_sleep) {
      player_destruct();
    }

=head1 DESCRIPTION

App::Pimpd::Player provides functions that allows for local playback of music
playing on a remote MPD server.

=head1 EXPORTS

=head2 play()

Starts remote and local playback.

=head2 stop()

Stops remote and local playback.

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
