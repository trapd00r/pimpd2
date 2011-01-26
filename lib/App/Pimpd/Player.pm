package App::Pimpd::Player;
use strict;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
    play
    stop
    player_init
    player_daemonize
    player_destruct
  );
}

my $DEBUG = $ENV{PIMPD2_DEBUG};

use Carp;
use App::Pimpd;

# NOTE To config
my $pidfile_pimpd   = '/tmp/pimpd2.pid';
my $pidfile_player  = '/tmp/pimpd2-player.pid';
my $player_tmp_log  = '/tmp/pimpd2.log';

my $cmdline = player_cmdline();

sub player_init {
  if(@_) {
    $cmdline = "@_";
  }
  my $fails = 0;

  # Not playing!
  if(! -e $player_tmp_log) {
    player_daemonize($player_tmp_log);
    exec($cmdline);
  }
  else {
    open(my $fh, '<', $player_tmp_log);
    while(<$fh>) {
      if(/Exiting\.\.\. \(End of file\)/m) {
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
    open(my $fh, '>', $pidfile_pimpd) or confess($!);
    print $fh $$;
    close($fh);

    waitpid($PID, 0);
    #unlink($pidfile); # remove the lock when child have confessd

    # Child have confessd/returned.
    # This means that MPD is in a state where it's not sending any data
    # We try to reconnect 20 times with a delay, and if the stream is still
    # down, we exit. See player_init()

    player_init();
    exit(0);
  }
  elsif($PID == 0) { # child
    open(my $fh, '>', "$pidfile_player") or confess("pidfile $pidfile_player: $!");
    print $fh $$;
    close($fh);
    open(STDOUT, '>>',  $daemon_log) unless $ENV{DEBUG};
    open(STDERR, '>', '/dev/null')   unless $ENV{DEBUG};
    open(STDIN,  '<', '/dev/null')   unless $ENV{DEBUG};
  }
  return 0;
}

sub play {
  player_destruct(); # FIXME
  $mpd->play;
  player_init(@_);

  #if(player_init() == 1) {
  #  $mpd->play;
  #}
  return;
}

sub stop {
  $mpd->stop;
  #unlink($player_tmp_log);
  player_destruct();

  return;
}

sub player_destruct {
  open(my $fh, '<', $pidfile_pimpd) or return 1; # for now
  my $pimpd_player = <$fh>;
  close($fh);

  if(kill(9, $pimpd_player)) {
    unlink($player_tmp_log);
    #printf("%s %s\n", fg('bold', $pimpd_player), 'terminated');
  }

  open(my $fh, '<', $pidfile_player) or confess($!);
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


1;

__END__

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

=over

=item play()

Starts remote and local playback.

=item stop()

Stops remote and local playback.

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
