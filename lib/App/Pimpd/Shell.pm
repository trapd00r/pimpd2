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
use App::Pimpd::Collection::Search;
use App::Pimpd::Playlist;
use App::Pimpd::Playlist::Favorite;
use App::Pimpd::Playlist::Remove;
use App::Pimpd::Playlist::Randomize;
use App::Pimpd::Playlist::Add;
use App::Pimpd::Validate;
use Term::ExtendedColor;
use Term::Complete;

=pod

=head1 NAME

App::Pimpd::Shell - interactive shell for pimpd2

=head1 EXPORTS

=head2 spawn_shell()

Spawns the interactive shell

=cut

sub spawn_shell {
  my $option = shift;
  my($cmd, $arg, @cmd_args); # for later use
  _shell_msg_help();


  my $opts = {

    'randomize'    => sub {
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


    'random-album'   => sub {
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


    'playlist'      => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty\n";
        return 1;
      }
      show_playlist();
      print fg('bold', ' >'), '> ', current(), "\n";
    },


    'love'       => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      add_to_favlist();
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

    'copy'        => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      cp($target_directory);
    },

    'copy-album'       => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      cp_album($target_directory);
    },

    # FIXME
    'copy-list'       => sub { cp_list(@_); },

    'i'         => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      info();
    },

    'monitor'       => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty - there's nothing to monitor\n";
        return 1;
      }
      monitor();
    },

    'sartist'       => sub {
      my $artist = join(' ', @_);
      add_to_playlist(search_db_artist($artist));
    },

    'salbum'       => sub {
      my $album = join(' ', @_);
      add_to_playlist(search_db_album($album));
    },

    'stitle'       => sub {
      my $title = join(' ', @_);
      add_to_playlist(search_db_title($title));
    },

    'sany'       => sub {
      my $search = join(' ', @_);
      add_to_playlist(search_db_quick($search));
    },

    #FIXME
    'splaylist'       => sub {
      my $search = join(' ', @_);
      search_playlist($search);
    },

    'sap'       => sub {
      my $search = join(' ', @_);
      search_all_playlists($search);
    },


    'albums'         => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      print "$_\n" for albums_by_artist(@_);
    },

    'songs'       => sub { print $_->file, "\n" for songs_on_album(@_); },

    'external'         => sub { list_external(@_); },

    #FIXME
    # The 0 argument makes sure we're not clearing the playlist
    # NOTE: Not really neccessary anymore
    'add'       => sub { add_playlist(0, @_); },

    'next'         => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty!\n";
        return 1;
      }
      next_track();
      print current() . "\n";
    },

    'previous'         => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty!\n";
        return 1;
      }
      previous_track();
      print current() . "\n";
    },

    'pause'         => sub {
      toggle_pause();
      print $mpd->status->state . "\n";
    },

    'shuffle'         => sub {
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

    'queue'         => sub {
      if(invalid_pos(@_)) {
        printf("No such song%s\n", (@_ < 1) ? 's' : '');
        return 1;
      }
      queue(@_);
    },

    'random'        => sub {
      $mpd->random;
      my $status =  ($mpd->status->random)
        ? "Random: " . fg('bold', 'On')
        : "Random: " . fg('bold', 'Off');
      print "$status\n";
    },

    'repeat'        => sub {
      $mpd->repeat;
      my $status = ($mpd->status->repeat)
        ? "Repeat: " . fg('bold', 'On')
        : "Repeat: " . fg('bold', 'Off');
      print "$status\n";
    },

    'randomtrack'        => sub {
      play_pos_from_playlist(random_track_in_playlist());
      print current(), "\n";
    },

    'add-album'        => sub { add_current_album(); },
    'clear'     => sub { clear_playlist() },
    'crop'        => sub { $mpd->playlist->crop; },
    'stop'      => sub { stop(); },
    'play'      => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      play();
    },

    'delalbum'       => sub { remove_album_from_playlist(@_); },
    'help'         => sub { _shell_msg_help(); },
    'exit'      => sub { exit(0); },
  };

  while(1) {
    print fg($c[6], 'pimpd'), fg('bold', '> ');

    #chomp(my $choice = <STDIN>);
    my @available_cmd = keys(%{$opts});
    my $choice = Complete(undef, \@available_cmd);
    ($cmd) = $choice =~ m/^(\w+)/;
    ($arg) = $choice =~ m/\s+(.+)$/;
    @cmd_args  = split(/\s+/, $arg);


    if(defined($opts->{$cmd})) {
      $mpd->play;
      $opts->{$cmd}->(@cmd_args);
    }
    else {
      $opts->{help}->();
      print STDERR "No such option ", fg($c[5], $cmd), "\n";
    }
  }
  exit(0);
}

sub _shell_msg_help {
  printf("%s %s\n%s

Options:
      np            show the current song
      info          show all current information
      songs         list songs on album
      albums        list albums by artist
      randomize     add n random songs to playlist
      random-album  add n random albums to playlist
      add           add files to playlist
      remove-album  remove album from playlist
      copy          copy song to destination
      copy-album    copy album to destination
      queue         put songs in a queue
      love          love song

Search:
      sartist       search for artist str
      salbum        search for album str
      stitle        search for title str
      sany          search database for str
      splaylist     search the current playlist for str

Controls:
      next          next track in playlist
      previous      previous track in playlist
      pause         toggle playback
      repeat        toggle repeat on/off
      random        toggle random on/off
      clear         clear playlist
      crop          remove all tracks but the current one from playlist

      clear         clear playlist
      crop          remove all tracks but the current from playlist

      help          show this help
      exit          exit pimpd2

        \n", shift,
      );
}




1;
