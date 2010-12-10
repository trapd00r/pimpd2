#!/usr/bin/perl
package App::Pimpd::Playlist;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  show_playlist
  play_pos_from_playlist
  queue
  songs_in_playlist
  add_playlist
  list_all_playlists
  add_to_playlist
);

use strict;
use Term::ExtendedColor;

use App::Pimpd;
use App::Pimpd::Validate;

sub add_to_playlist {
  my @songs = @_;

  if(ref($songs[0] eq 'ARRAY')) {
    push(@songs, @{$songs[0]});
    shift(@songs);
  }
  chomp(@songs);

  $mpd->playlist->add(@songs);

  # Start playback. Often one wants to clear the playlist and add a bunch of
  # new, maybe randomized, content. When the playlist is cleared, playback will
  # stop.
  # If using the player() functionality, we have around 20s to start playback
  # again. 20s ought to be enough for everybody.
  $mpd->play;
  return 0;
}


sub add_playlist {
  my @lists = get_valid_lists(@_);
  for(@lists) {
    $mpd->playlist->load($_);
  }
  $mpd->play;
  return 0;
}

sub songs_in_playlist {
  my @playlists = @_;

  @playlists = get_valid_lists(@playlists);
  for my $playlist(@playlists) {
    my $full_path = "$playlist_directory/$playlist\.m3u";

    my $fh = undef;
    if(remote_host()) {
      open($fh, "ssh -p $ssh_port $ssh_user\@$ssh_host \"/bin/cat '$full_path'\"|")
        or die("$ssh_host:$ssh_port: $!");
    }
    else {
      open($fh, '<', $full_path) or die("Can not open $full_path: $!");
    }
    while(<$fh>) {
      print fg($c[4], $playlist), ': ', fg($c[10], $_);
    }
    close($fh);
  }
  return 0;
}

sub play_pos_from_playlist {
  my $track_no = shift;

  if(invalid_playlist_pos($track_no)) {
    print STDERR "Playlist index '$track_no' is invalid\n";
    return 1;
  }
  $mpd->play($track_no);
}

sub queue {
  my @to_play = @_;
  if(scalar(@to_play < 1)) {
    print STDERR "The queue function requires at least one song \n";
    return 1;
  }

  for(@to_play) {
    if(invalid_playlist_pos($_)) {
      print STDERR fg($c[5], $_), ": invalid position\n";
      return 1;
    }
  }

  my %list = ();
  map { $list{$_->pos} = $_->title } $mpd->playlist->as_items;


  $mpd->random(0);
  $mpd->play(shift(@to_play));
  $mpd->playlist->move($mpd->current->pos, 0);

  return 0 if(scalar(@to_play) == 0);


  my $next_pos = $mpd->current->pos + 1;
  print fg('bold', 'Queueing'), ":\n";
  for(@to_play) {
    printf("%-50.50s %s\n", fg($c[3], $list{$_}), "( $_ => $next_pos )");
    #print "$_ => ", fg('bold', $next_pos), "\n" if($DEBUG);

    $mpd->playlist->move($_, $next_pos);
    $next_pos++;
  }
}

sub show_playlist {
  my @playlist = $mpd->playlist->as_items;

  my $i = 0;
  for my $song(@playlist) {
    my $title  = $song->title  // 'undef';
    my $artist = $song->artist // 'undef';


    my $crnt_title  = $mpd->current->title // undef;
    my $crnt_artist = $mpd->current->artist // undef;
    $title       =~ s/(\w+)/\u\L$1/g;
    $artist      =~ s/(\w+)/\u\L$1/g;
    $crnt_title  =~ s/(\w+)/\u\L$1/g;
    $crnt_artist =~ s/(\w+)/\u\L$1/g;

    if($mpd->current->pos == $i) {
      # bg('red4', $i) will add another 17 chars

      printf("%19s %51.51s |@{[fg('bold', 'x')]}| %-47.47s\n",
        bg('red4', $i), fg('red1', fg('bold',  $artist)), $title);

    }
    else {
      printf("%4d %25.25s | | %-47.47s\n",
        $i, $artist, $title);
    }
    $i++;
  }
}

sub list_all_playlists {
  return wantarray()
    ? sort($mpd->collection->all_playlists)
    : scalar($mpd->collection->all_playlists)
    ;
}


=pod

=head1 NAME

App::Pimpd::Playlist - Functions dealing with the current playlist

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Playlist;

    add_playlist(@playlists);
    play_pos_from_playlist(42);

    queue(4, 12, 9, 18);

=head1 DESCRIPTION

App::Pimpd::Playlist provides functions playing with the current playlist

=head1 EXPORTS

=head2 add_playlist()

  add_playlist('rock');

Parameters: @playlists

Tries hard to find valid, existing playlists based on input.
If a playlist doesn't exist, tries to match the strings against the existing
ones (using B<get_valid_lists()> from B<App::Pimpd::Validate>), presenting
the user with a prompt.

get_valid_lists() returns a list of valid playlists which we add to the current
playlist.

=head2 play_pos_from_playlist()

  play_pos_from_playlist(42);

Parameters: $playlist_pos

Play $playlist_pos in the current playlist.

=head2 queue()

  queue(42, 3, 9, 18, 12);

Parameters: @playlist_positions

Simulates a queue by turning random mode off and moving the supplied playlist
position IDs up in order.

=head2 show_playlist()

Show the current playlist.

=head2 songs_in_playlist()

Parameters: @playlists

Takes a list of existing playlists and prints the content.

=head2 list_all_playlists()

In list context, returns a list with known playlists.

In scalar context, returns the number of knows playlists.

=head2 add_to_playlist()

Parameters: @paths | \@paths

Adds the list of songs (paths) to the current playlist.

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
