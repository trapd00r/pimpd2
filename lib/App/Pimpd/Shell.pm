#!/usr/bin/perl
package App::Pimpd::Shell;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  spawn_shell
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
use App::Pimpd::Info;
use App::Pimpd::Player;
use App::Pimpd::Commands;
use App::Pimpd::Transfer;
use App::Pimpd::Collection::Album;
use App::Pimpd::Playlist;
use App::Pimpd::Playlist::Randomize;
use App::Pimpd::Playlist::Add;
use App::Pimpd::Validate;
use Term::ExtendedColor;


=head3 spawn_shell()

Spawns the interactive shell

=cut 

sub spawn_shell {
  my $option = shift;
  my($cmd, $arg, @cmd_args); # for later use
  _shell_msg_help();

  my $opts = {

    'rand'    => sub {
      if(!defined($_[0])) {
        $_[0] = 100;
      }
      elsif(defined($_[0]) and $_[0] !~ /^\d+$/) {
        print STDERR "Need a valid integer\n";
        $_[0] = 100;
      }
      print 'Adding ' . fg('bold', @_) . " random tracks...\n";
      my @random = randomize(@_);

      print "$_\n" for @random;
      clear_playlist();
      add_to_playlist(@random);
    },


    'randa'   => sub {
      $_[0] = 10 if(!$_[0]);
      print 'Adding ' . fg('bold', $_[0]) . " random albums...\n\n";
      my @albums = randomize_albums($_[0]);

      my $old = undef;
      for(@albums) {
        my($album_dir) = $_ =~ m|(.+)/.+|;
        if($old ne $album_dir) {
          print "> $album_dir\n";
          $old = $album_dir;
        }
      }
      print "\n";
      add_to_playlist(@albums);
    },


    'list'      => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty\n";
        return 1;
      }
      show_playlist();
      print fg('bold', ' >'), '> ', current(), "\n";
    },


    # FIXME
    'fav'       => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      write_favlist(@_);
    },


    # FIXME
    'favstats'  => sub {
      if($_[0] eq 'all') {
        favlist_stats(1);
      }
      else {
        favlist_stats(0);
      }
    },

    #FIXME
    'track'      => sub {
      $_[0] = 1 if $_[0] !~ /^\d+$/;
      play_pos_from_playlist(@_);
    },

    'cp'        => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      cp($target_directory);
    },

    'cpa'       => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      cp_album($target_directory);
    },

    # FIXME
    'cpl'       => sub { cp_list(@_); },

    'i'         => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      info();
    },

    'mon'       => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty - there's nothing to monitor\n";
        return 1;
      }
      monitor();
    },

    'sar'       => sub {
      my $artist = join(' ', @_);
      search_artist($artist);
    },

    'sal'       => sub {
      my $album = join(' ', @_);
      search_album($album);
    },

    'set'       => sub {
      my $title = join(' ', @_);
      search_title($title);
    },

    'sdb'       => sub {
      my $search = join(' ', @_);
      search_db($search);
    },

    'spl'       => sub {
      my $search = join(' ', @_);
      search_playlist($search);
    },

    'sap'       => sub {
      my $search = join(' ', @_);
      search_all_playlists($search);
    },

    'l'         => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      list_albums();
    },
    'lsa'       => sub { print $_->file, "\n" for songs_on_album(@_); },

    'e'         => sub { list_external(@_); },

    # The 0 argument makes sure we're not clearing the playlist
    # NOTE: Not really neccessary anymore
    'add'       => sub { add_playlist(0, @_); },

    'n'         => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty!\n";
        return 1;
      }
      next_track();
      print current() . "\n";
    },

    'p'         => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty!\n";
        return 1;
      }
      previous_track();
      print current() . "\n";
    },

    't'         => sub {
      toggle_pause();
      print $mpd->status->state . "\n";
    },

    's'         => sub {
      $mpd->playlist->shuffle;
      print "New playlist version is " .$mpd->status->playlist . "\n"
    },

    'np'        => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      print current() . "\n";
    },

    'nprt'      => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      np_realtime();
    },

    'q'         => sub {
      if(invalid_pos(@_)) {
        printf("No such song%s\n", (@_ < 1) ? 's' : '');
        return 1;
      }
      queue(@_);
    },

    'ra'        => sub {
      $mpd->random;
      my $status =  ($mpd->status->random)
        ? "Random: " . fg('bold', 'On')
        : "Random: " . fg('bold', 'Off');
      print "$status\n";
    },

    're'        => sub {
      $mpd->repeat;
      my $status = ($mpd->status->repeat)
        ? "Repeat: " . fg('bold', 'On')
        : "Repeat: " . fg('bold', 'Off');
      print "$status\n";
    },

    'rt'        => sub { random_track_in_playlist(); },
    'aa'        => sub { add_current_album(); },
    'clear'     => sub { clear_playlist() },
    'cr'        => sub { $mpd->playlist->crop; },
    'stop'      => sub { stop(); },
    'play'      => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      play();
    },
    'h'         => sub { _shell_msg_help(); },
    'exit'      => sub { exit(0); },
  };

  while(1) {
    print fg($c[6], 'pimpd'), fg('bold', '> ');

    chomp(my $choice = <STDIN>);
    ($cmd) = $choice =~ m/^(\w+)/;
    ($arg) = $choice =~ m/\s+(.+)$/;
    @cmd_args  = split(/\s+/, $arg);


    if(defined($opts->{$cmd})) {
      $mpd->play;
      $opts->{$cmd}->(@cmd_args);
    }
    else {
      $opts->{h}->();
      print STDERR "No such option ", fg($c[5], $cmd), "\n";
    }
  }
  exit(0);
}

sub _shell_msg_help {
  printf("%s %s\n%s
    OPTIONS:
        play           start playback
        stop           stop playback
        rand      n    randomize a new playlist with n tracks
        randa     n    add n random albums to a new playlist
        track     n    play track n in playlist
        add       s    add playlist s
        aa        NIL  add the full album of the currently playing song
        sdb       p    search the database for pattern
        sar       p    search for artists matching pattern
        sal       p    search for albums matching pattern
        set       p    search for titles matching pattern
        spl       p    search the playlist for pattern
        fav       NIL  add the current track to the favorites
        favstats  NIL  generate statistics from all favlists
        list      NIL  show the current playlist
        lsa       (n)  list all songs on the current album
        i         NIL  show now playing information
        np        NIL  show the currently playing track
        nprt      NIL  show the currently playing track and progress in realtime
        cp        NIL  copy the currently playing track to specifed location
        cpl       (s)  copy the content of playlist s to specifed location
        rt        NIL  play a random track from the playlist
        n         NIL  next track
        p         NIL  previous track
        s         NIL  shuffle the playlist
        ra        NIL  toggle random on/off
        re        NIL  toggle repeat on/off
        cl        NIL  clear the current playlist
        cr        NIL  crop the current track
        q         n    queue n tracks
        l         NIL  list all albums featuring artist
        e         s    list all tracks in playlist s

        h         NIL  show this help

        exit      NIL  exit


        \n", shift,
      );
}




1;
