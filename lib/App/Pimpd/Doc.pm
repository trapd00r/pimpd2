#!/usr/bin/perl
package App::Pimpd::Doc;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  help
);

use strict;
use App::Pimpd;
use Term::ExtendedColor;

sub help {
  my $cmd = shift;

  my %help = (

  # Controls
    'next'          => \&_help_next,
    'previous'      => \&_help_previous,
    'pause'         => \&_help_pause,
    'repeat'        => \&_help_repeat,
    'random'        => \&_help_random,
    'clear'         => \&_help_clear,
    'crop'          => \&_help_crop,
    'kill'          => \&_help_kill,
    'stop'          => \&_help_stop,

  # Collection
    'songs'         => \&_help_songs,
    'albums'        => \&_help_albums,
    'sany'          => \&_help_sany,
    'sartist'       => \&_help_sartist,
    'salbum'        => \&_help_salbum,
    'stitle'        => \&_help_stitle,
    'slove'         => \&_help_slove,

  # Playlist
    'playlist'      => \&_help_playlist,
    'playlists'     => \&_help_playlists,
    'add-files'     => \&_help_add_files,
    'add-playlist'  => \&_help_add_playlist,
    'randomize'     => \&_help_randomize,
    'randomalbum'   => \&_help_randomize_albums,
    'randomtrack'   => \&_help_random_track,
    'rmalbum'       => \&_help_rm_album,
    'love'          => \&_help_love,
    'loved?'        => \&_help_loved,
    'external'      => \&_help_external,
    'splaylist'     => \&_help_splaylist,


  # Options
    'queue'         => \&_help_queue,
    'shell'         => \&_help_shell,
    'help'          => \&_help_shell,
    'copy'          => \&_help_copy,
    'info'          => \&_help_info,
    'np'            => \&_help_np,
  );

  if(exists($help{$cmd})) {
    return $help{$cmd}->();
  }
  else {
    return "No such topic.\n";
  }
}

sub _help_slove {
  return << "EOF"
@{[fg('bold', 'Usage')]}: slove PATTERN

Search the database with loved songs for PATTERN.

If PATTERN is omitted, returns all loved songs.

The results are added to the current playlist.
EOF
}

sub _help_random_track {
  return << "EOF"
@{[fg('bold', 'Usage')]}: randomtrack

Play a random song from the current playlist.
EOF
}

sub _help_stop {
  return << "EOF"
@{[fg('bold', 'Usage')]}: stop

Stop @{[fg('bold', 'local and remote')]} playback.
EOF
}


sub _help_kill {
  return << "EOF"
@{[fg('bold', 'Usage')]}: kill

Stop @{[fg('bold', 'local')]} playback.
EOF
}

sub _help_crop {
  return << "EOF"
@{[fg('bold', 'Usage')]}: crop

Remove all but the current song from the playlist.
EOF
}


sub _help_clear {
  return << "EOF"
@{[fg('bold', 'Usage')]}: clear

Clear the current playlist.
EOF
}

sub _help_random {
  return << "EOF"
@{[fg('bold', 'Usage')]}: random

Toggle random on/off.
EOF
}

sub _help_repeat {
  return << "EOF"
@{[fg('bold', 'Usage')]}: repeat

Toggle repeat on/off.
EOF
}

sub _help_pause {
  return << "EOF"
@{[fg('bold', 'Usage')]}: pause

Toggle playback status.
EOF
}

sub _help_previous {
  return << "EOF"
@{[fg('bold', 'Usage')]}: previous

Play the previous song in playlist.
EOF
}

sub _help_next {
  return << "EOF"
@{[fg('bold', 'Usage')]}: next

Play the next song in playlist.
EOF
}


sub _help_stitle {
  return << "EOF"
@{[fg('bold', 'Usage')]}: sartist TITLE

Search the collection for songs where the title tag
@{[fg('bold', 'partially')]} matches TITLE.
The results are added to the current playlist.
EOF
}

sub _help_salbum {
  return << "EOF"
@{[fg('bold', 'Usage')]}: sartist ALBUM

Search the collection for songs where the album tag
@{[fg('bold', 'partially')]} matches ALBUM.
The results are added to the current playlist.
EOF
}
sub _help_sartist {
  return << "EOF"
@{[fg('bold', 'Usage')]}: sartist ARTIST

Search the collection for songs where the artist tag
@{[fg('bold', 'partially')]} matches ARTIST.
The results are added to the current playlist.
EOF
}



sub _help_sany {
  return << "EOF"
@{[fg('bold', 'Usage')]}: sany PATTERN

Search the collection for filenams matching PATTERN.
The results are added to the current playlist.
EOF
}


sub _help_albums {
  return << "EOF"
@{[fg('bold', 'Usage')]}: albums [ARTIST]

List albums where ARTIST is featured.
If ARTIST is omitted, use the artist tag from the currently
playing song.
EOF
}


sub _help_songs {
  return << "EOF"
@{[fg('bold', 'Usage')]}: songs [ALBUM]

List songs on ALBUM.
If ALBUM is omitted, use the album tag from the currently playing
song.
EOF
}



sub _help_queue {
  return << "EOF"
@{[fg('bold', 'Usage')]}: queue INTEGERs

Put songs in a queue.
Arguments need to be valid playlist position IDs, as shown in
the 'playlist' output.
EOF
}

sub _help_splaylist {
  return << "EOF"
@{[fg('bold', 'Usage')]}: splaylist PATTERN

Search the current playlist for PATTERN.
If more then one result is found, queue up the results.

See 'help queue'.
EOF
}

sub _help_external {
  return << "EOF"
@{[fg('bold', 'Usage')]}: external PLAYLISTs

List songs in external, by MPD known playlists.

PLAYLIST can be a partial name, or a regular expression.
Thus;

  @{[fg($c[0], 'external 2010-12')]}

might resolve to something like;

  0 2010-12-indie
  1 2010-12-other
  2 2010-12-pop
  3 2010-12-punk_rock
  4 2010-12-rock
  5 2010-12-undef

Type the corresponding number for the playlist you want to see,
or just hit <enter> to show all of them.
EOF
}


sub _help_love {
  return << "EOF"
@{[fg('bold', 'Usage')]}: love [PLAYLIST]

Add the currently playing track to the library of loved songs.
If PLAYLIST is omitted, the song is added to a playlist following
this naming scheme:

  @{[fg($c[0], '%year-%month-%genre.m3u')]}

If a genre tag is missing, the string 'undef' is used in its place.
EOF
}

sub _help_loved {
  return << "EOF"
@{[fg('bold', 'Usage')]}: loved?

Check if the current song is already loved.
EOF
}

sub _help_rm_album {
  return << "EOF"
@{[fg('bold', 'Usage')]}: rmalbum PATTERN

Search the current playlist for albums matching PATTERN and
removes the matches from the playlist.
EOF
}



sub _help_playlists {
  return << "EOF"
@{[fg('bold', 'Usage')]}: playlists

List all by MPD known playlists.
EOF
}


sub _help_playlist {
  return << "EOF"
@{[fg('bold', 'Usage')]}: playlist

Show the current playlist.
EOF
}


sub _help_shell {
  return sprintf("\n%s%s",
  "@{[fg('bold', fg($c[8], 'OPTIONS'))]}\t\t    " .
  "@{[fg('bold', fg($c[3], 'DESCRIPTION'))]} \t\t\t\t   "
,"
      np            show the current song
      info          show all current information
      copy          copy song to destination
      copya         copy album to destination
      queue         put songs in a queue

@{[fg('bold', fg($c[0], '  Playlist'))]}
      playlists     list all known playlists
      add           add playlist
      rmalbum       remove album from playlist
      randomize     randomize a new playlist with n tracks
      randomalbum   and n random full albums
      love          love song
      loved?        check if the current song is loved
      splaylist     search the current playlist for str

@{[fg('bold', fg($c[0], '  Collection'))]}
      songs         list songs on album
      albums        list albums by artist
      sartist       search for artist str
      salbum        search for album str
      stitle        search for title str
      sany          search database for str
      slove         search the database with loved songs for pattern

@{[fg('bold', fg($c[0], '  Controls'))]}
      next          next track in playlist
      previous      previous track in playlist
      pause         toggle playback
      repeat        toggle repeat on/off
      random        toggle random on/off
      clear         clear playlist
      crop          remove all tracks but the current one
      kill          stop local playback

      help          show help for command
      exit          exit pimpd2

        \n", shift,
      );
}


sub _help_copy {
  return << "EOF"
@{[fg('bold', 'Usage')]}: copy [DESTINATION]

Copy the currently playing song to DESTINATION.

If DESTINATION is omitted, use the @{[fg($c[0], '$target_directory')]}
setting defined in @{[fg('bold', 'pimpd2.conf')]}.
EOF
}


sub _help_info {
  return << "EOF"
@{[fg('bold', 'Usage')]}: info

Show all available song metadata, as well as playback status
and various MPD settings.
EOF
}


sub _help_np {
  return << "EOF"
@{[fg('bold', 'Usage')]}: np

Show basic song metadata on a single line.
EOF
}



sub _help_randomize {
  return << "EOF"
@{[fg('bold', 'Usage')]}: randomize [INTEGER] [ARTIST]

Add n random songs from the collection to the current playlist.

The first, optional argument, is the number of songs to add.
The second, optional argument, is an artist name.
If a second argument is provided, add n random songs from that artist.

Defaults to 100 random songs.
EOF
}

sub _help_randomize_albums {
return << "EOF"
@{[fg('bold', 'Usage')]}: randomalbum [INTEGER]

Add n random full albums to the current playlist.

Defaults to 10 albums.
EOF
}
