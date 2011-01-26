package App::Pimpd::Playlist;
use strict;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
    show_playlist
    play_pos_from_playlist
    queue
    songs_in_playlist
    add_playlist
    list_all_playlists
    add_to_playlist
    get_album_songs
  );
}

#TODO
#  List content in all playlist
#  Search all playlist, without args, search for the current song

use App::Pimpd;
use App::Pimpd::Validate;
use Term::ExtendedColor qw(fg bg);

sub get_album_songs {
  my $album = shift // $mpd->current->album;
  if( (!defined($album)) or ($album eq '') ) {
    return;
  }

  my @tracks = $mpd->collection->songs_from_album($album);
  return wantarray() ? @tracks : scalar(@tracks);
}

sub remove_album_from_playlist {
  my $search_str = shift;

  my @removed;
  for($mpd->playlist->as_items) {
    if($_->album =~ m/$search_str/gim) {
      if(not(invalid_playlist_pos($_->pos))) {
        $mpd->playlist->delete($_->pos);
      }
    }
  }
  return;
}

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
    my $full_path = $config{playlist_directory} . "/$playlist.m3u";

    my $fh = undef;
    if(remote_host()) {
      #FIXME 80c !
      open($fh,
        "ssh -p $config{ssh_port} $config{ssh_user}\@$config{ssh_host} \"/bin/cat '$full_path'\"|"
      ) or die("ssh: $config{ssh_host}:$config{ssh_port}:\n$!\n");
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
  return;
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

    $mpd->playlist->move($_, $next_pos);
    $next_pos++;
  }
  return;
}

sub show_playlist {
  my @playlist = $mpd->playlist->as_items;

  my $i = 0;
  for my $song(@playlist) {
    my $title  = $song->title  // 'undef';
    my $artist = $song->artist // 'undef';


    my $crnt_title  = $mpd->current->title // undef;
    my $crnt_artist = $mpd->current->artist // undef;
    $title       =~ s/(\w+)/\u\L$1/gm;
    $artist      =~ s/(\w+)/\u\L$1/gm;
    $crnt_title  =~ s/(\w+)/\u\L$1/gm;
    $crnt_artist =~ s/(\w+)/\u\L$1/gm;

    if($mpd->current->pos == $i) {
      # bg('red4', $i) will add another 17 chars

      printf("%19s %51.51s |@{[fg('bold', 'x')]}| %-47.47s\n",
        bg($c[4], $i), fg($c[5], fg('bold',  $artist)), $title);

    }
    else {
      printf("%4d %25.25s | | %-47.47s\n",
        $i, $artist, $title);
    }
    $i++;
  }
  return;
}

sub list_all_playlists {
  return wantarray()
    ? sort($mpd->collection->all_playlists)
    : scalar($mpd->collection->all_playlists)
    ;
}


1;

__END__


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

=over

=item add_playlist()

  add_playlist('rock');

Parameters: @playlists

Tries hard to find valid, existing playlists based on input.
If a playlist doesn't exist, tries to match the strings against the existing
ones (using B<get_valid_lists()> from B<App::Pimpd::Validate>), presenting
the user with a prompt.

get_valid_lists() returns a list of valid playlists which we add to the current
playlist.

=item play_pos_from_playlist()

  play_pos_from_playlist(42);

Parameters: $playlist_pos

Play $playlist_pos in the current playlist.

=item queue()

  queue(42, 3, 9, 18, 12);

Parameters: @playlist_positions

Simulates a queue by turning random mode off and moving the supplied playlist
position IDs up in order.

=item show_playlist()

Show the current playlist.

=item songs_in_playlist()

Parameters: @playlists

Takes a list of existing playlists and prints the content.

=item list_all_playlists()

In list context, returns a list with known playlists.

In scalar context, returns the number of knows playlists.

=item add_to_playlist()

Parameters: @paths | \@paths

Adds the list of songs (paths) to the current playlist.

=item remove_album_from_playlist()

Parameters: $regex

Tries to remove all albums matching $regex from the current playlist.

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
