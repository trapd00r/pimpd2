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
);

use strict;
use Term::ExtendedColor;

use App::Pimpd;
use App::Pimpd::Validate;

=pod

=head1 NAME

App::Pimpd::Playlist - base class for dealing with MPD playlists

=head1 EXPORTS


=cut

sub add_playlist {
  my @lists = get_valid_lists(@_);
  for(@lists) {
    $mpd->playlist->load($_);
  }
  $mpd->play;
  return 0;
}


=head2 play_pos_from_playlist()

  play_pos_from_playlist(42);

Takes a playlist id as the first argument, and plays it.

No return value.

=cut

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

=head2 queue()

  queue(@playlist_pos);

Takes a list of playlist IDs, and rearranges them in the playlist to build up a
queue.

No return value.

=cut

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

=head2 show_playlist()

  show_playlist()

Show the playlist.

No return value.

=cut

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


1;
