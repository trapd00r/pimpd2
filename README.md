[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=65SFZJ25PSKG8&currency_code=SEK&source=url) - Every tiny cent helps a lot!

# NAME

pimpd2 - Perl Interface for the Music Player Daemon 2

# DESCRIPTION

pimpd2 is a command-line based MPD client that implements all the features
the author was missing from the other awesome client, mpc.


![pimpd2](/extra/pimpd2.png)


# FEATURES

## -np, --now-playing

Show basic song information on a single line.

## -i, --info

Show all available song information and MPD server status.

## -cp, --copy

Copy the currently playing song to destination.

If destination is omitted, uses the `target_directory` variable from the
configuration file.

## -cpa, --copy-album

Copy the currently playing album to destination.

If destination is omitted, uses the `target_directory` variable from the
configuration file.

## -sh, --shell

Spawn the interactive pimpd2 shell.

All the regular features can be used. Commands that return data that can be
added to the current playlist will do so automagically for convenience, since
we can not read from standard input while being interactive.

## -q, --queue

Queue tracks. Arguments must be valid playlist position IDs as shown in the
`--playlist` output.

You can also use the `--search-playlist` command if the tracks to be queued
follows a pattern.

# PLAYLIST INTERACTION

## -pls, --playlist

Show the current playlist.

## --playlists

List all playlists known by MPD.

## -af, --add-files

Add files to the current playlist.

Can read from standard input:

    pimpd2 --randomize 42 Nirvana | pimpd2 -af

Accepts file arguments:

    pimpd2 -af ~/music/Nirvana/Bleach/*.flac

## -a, --add-playlist

Add playlist to the current playlist.

If not given a full name, and the name partially matches existing playlists,
prompts for input:

    pimpd2 -a 2010

      0 2010-12-indie
      1 2010-12-other
      2 2010-12-pop
      3 2010-12-punk_rock
      4 2010-12-rock
      5 2010-12-undef
    choice:

If choice equals 'all', all matching playlists are added.

## -r, --randomize

Return **n** random songs from the collection.
The first argument is the number of songs, the second argument is an optional
artist name. If an artist name is specified, will only return random songs from
that particular artist.

If no arguments are specified, returns 100 random songs.

If you want to add the results to the current playlist, pipe it to `--add-files`:

    pimpd2 -r 12 | pimpd2 -af

Or use the interactive shell ( `-sh` ) which does this for you automatically.

## -ra, --random-album

Return **n** random full albums.

A pipe to `--add-files` will add the results to the current playlist.

## -rma, --rmalbum

Given a string, searches the current playlist for matching albums, and remove
them from the playlist. The string can be a regular expression.

## -da, --delete-album

Delete the current album from disk.

## -f, --love

Favorize, or love, the current song.

If called with zero arguments, the song will be saved to a playlist following
this naming scheme:

    %year-%month-%genre.m3u

Else, the argument is used for the playlist name, thus:

    pimpd2 --love lovesongs

adds the song to lovesongs.m3u

## --loved

Check if the currently playing song is already loved or not.

## --unlove

Unlove songs matching given PATTERN.

## --lsplaylists

Lists available playlists.

## --slove

Search the database with loved songs for PATTERN.

If PATTERN is omitted, returns all loved songs.

## -spl, --search-playlist

Search the current playlist for string, possibly a regular expression.

If more then one song is found, queues up the results. See `--queue`.

# COLLECTION INTERACTION

## -lsa, --songs

List all songs on album.

If no argument is specified, use the album tag from the currently playing song.

A pipe to `--add-files` will add the results to the current playlist:

    pimpd2 -lsa Stripped | pimpd2 -af

## -l, --albums

List all albums where artist is featured.

If no argument is specified, use the artist tag from the currently playing song.

## -sdb, --search-db

Search the database for string, possibly a regular expression.

A pipe to `--add-files` will add the results to the current playlist:

## -sar, --search-artist

Search the database for artist.

A pipe to `--add-files` will add the results to the current playlist:

## -sal, --search-album

Search the database for album.

A pipe to `--add-files` will add the results to the current playlist:

## -set, --search-title

Search the database for title.

A pipe to `--add-files` will add the results to the current playlist:

## --stats

Display statistics about MPD

## --status

Display MPD status

# CONTROLS

## -n, --next

Play the next track in the playlist.

## -p, --previous

Play the previous track in the playlist.

## -cl, --clear

Clear the current playlist.

## -cr, --crop

Remove all songs but the current one from the playlist.

## -x, --xfade

Set crossfade.

## --pause

Toggle playback status.

## --repeat

Toggle repeat on/off

## --random

Toggle random on/off

## --play

Start playback.

If a remote stream URL and an external player is specified in the
configuration file, starts playback on the local machine as well as on the
MPD server.

## --stop

Stop playback, locally and remote.

## --kill

Stop local playback.

# OPTIONS

    -np,   --now-playing      basic song info on a single line
    -i,    --info             full song info
    -cp,   --copy             copy the current track to destination
    -cpa,  --copy-album       copy the current album to destination
    -sh,   --shell            spawn the interactive shell
    -q,    --queue            queue tracks

## Playlist

    -pls,  --playlist         show the current playlist
           --playlists        list all known playlists
    -af,   --add-files        add files to playlist
    -a,    --add-playlist     add playlist
           --randomize        randomize a new playlist with n tracks
    -ra,   --random-album     add n random full albums
    -rma,  --rmalbum          remove album matching pattern from playlist
    -da,   --delete-album     delete the current album from disk
    -f,    --love             love song
           --loved            check if the current song is loved
    -u,    --unlove           unlove songs matching pattern
    -spl,  --search-playlist  search the current playlist for str

## Collection

    -lsa,  --songs            list songs on album
    -l,    --albums           list albums by artist
    -sdb,  --search-db        search database for pattern
    -sar,  --search-artist    search database for artist
    -sal,  --search-album     search database for album
    -set,  --search-title     search database for title
           --slove            search the database with loved songs for pattern
           --stats            display statistics about MPD
           --status           display MPD status

## Controls

    -n,    --next             next track in playlist
    -p,    --previous         previous track in playlist
    -cl,   --clear            clear the playlist
    -cr,   --crop             remove all songs but the current one from playlist
    -x,    --xfade            set crossfade
           --pause            toggle playback status
           --repeat           toggle repeat mode
           --random           toggle random mode

    -p,    --play             start playback (locally and remote)
    -s,    --stop             stop playback (locally and remote)
    -k,    --kill             stop playback (locally)

    -h,    --help             show the help and exit
    -m,    --man              show the manual and exit
    -v,    --version          show version info and exit

# ENVIRONMENT

pimpd2 will look for a configuration file in the following locations, in this
order:

    $XDG_CONFIG_HOME/pimpd2/pimpd2.conf
    ~/.config/pimpd2/pimpd.conf
    ~/.pimpd2.conf
    ./pimpd2.conf
    /etc/pimpd2.conf

# AUTHOR

    Magnus Woldrich
    CPAN ID: WOLDRICH
    magnus@trapd00r.se
    http://japh.se

# CONTRIBUTORS

None required yet.

# REPORTING BUGS

Report bugs and/or feature requests to <magnus@trapd00r.se>, on [rt.cpan.org](https://metacpan.org/pod/rt.cpan.org)
or [http://github.com/trapd00r/pimpd2/issues](http://github.com/trapd00r/pimpd2/issues).

# COPYRIGHT

Copyright 2009, 2010, 2011 the **pimpd2** ["AUTHOR"](#author) and ["CONTRIBUTORS"](#contributors) as
listed above.

# LICENSE

This application is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

# SEE ALSO

[mpd(1)](http://man.he.net/man1/mpd)

[App::Pimpd::Collection::Album](https://metacpan.org/pod/App::Pimpd::Collection::Album), [App::Pimpd::Collection::Search](https://metacpan.org/pod/App::Pimpd::Collection::Search),
[App::Pimpd::Commands](https://metacpan.org/pod/App::Pimpd::Commands), [App::Pimpd::Doc](https://metacpan.org/pod/App::Pimpd::Doc), [App::Pimpd::Info](https://metacpan.org/pod/App::Pimpd::Info),
[App::Pimpd::Player](https://metacpan.org/pod/App::Pimpd::Player), [App::Pimpd::Playlist](https://metacpan.org/pod/App::Pimpd::Playlist),
[App::Pimpd::Playlist::Favorite](https://metacpan.org/pod/App::Pimpd::Playlist::Favorite), [App::Pimpd::Playlist::Randomize](https://metacpan.org/pod/App::Pimpd::Playlist::Randomize),
[App::Pimpd::Playlist::Search](https://metacpan.org/pod/App::Pimpd::Playlist::Search), [App::Pimpd::Shell](https://metacpan.org/pod/App::Pimpd::Shell), [App::Pimpd::Transfer](https://metacpan.org/pod/App::Pimpd::Transfer),
[App::Pimpd::Validate](https://metacpan.org/pod/App::Pimpd::Validate)
