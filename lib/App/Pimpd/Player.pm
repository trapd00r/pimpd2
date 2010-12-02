#!/usr/bin/perl
package App::Pimpd::Player;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  play
  stop
  player_init
  player_daemonize
  player_destruct
);

use strict;
use Carp;
use Data::Dumper;
use Term::ExtendedColor;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;

use App::Pimpd;

# NOTE To config
my $player          = 'mplayer';
my $player_stream   = 'http://192.168.1.100:9999';
my $player_temp_log = '/tmp/pimpd2_player.log';
my $pidfile_pimpd   = '/tmp/pimpd2.pod';
my $pidfile_player  = '/tmp/pimpd2-player.pid';

sub player_init {
  if(!defined($player)) {
    #print STDERR "No player configured\n";
    return 1;
  }
  if(!defined($player_stream)) {
    #print STDERR "No stream configured\n";
    return 1;
  }

  my $fails = 0;

  # Not playing!
  if(! -e $player_temp_log) {
    player_daemonize($player_temp_log);
    exec($player, $player_stream);
  }
  else {
    open(my $fh, '<', $player_temp_log);
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
    unlink($player_temp_log);
    #player_destruct();
    return 0;
  }
  else {
    player_daemonize($player_temp_log);
    exec($player, $player_stream);
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
    player_init($player_stream);
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
  #unlink($player_temp_log);
  player_destruct();
}

sub player_destruct {
  open(my $fh, '<', $pidfile_pimpd) or return 1; # for now
  my $pimpd_player = <$fh>;
  close($fh);

  if(kill(9, $pimpd_player)) {
    unlink($player_temp_log);
    printf("%d %s\n", fg('bold', $pimpd_player), 'terminated');
  }

  open(my $fh, '<', $pidfile_player) or die($!);
  my $pimpd_target = <$fh>;
  close($fh);

  if(kill(9, $pimpd_target)) {
    printf("%d %s\n", fg('bold', $pimpd_target, 'terminated'));
  }

  if(kill(9, $pimpd_target+1)) {
    printf("%d %s\n", fg('bold', $pimpd_target + 1), 'terminated');
  }
  return 0;
}


1;
