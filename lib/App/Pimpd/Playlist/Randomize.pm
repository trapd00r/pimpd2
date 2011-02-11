package App::Pimpd::Playlist::Randomize;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
    randomize
    randomize_albums
    random_track_in_playlist
  );
}

use strict;

use App::Pimpd;
use App::Pimpd::Validate;
use List::Util 'shuffle';


sub randomize {
  my($no_songs, $artist) = (100, undef);
  my(@songs, @random);

  # artist provided.
  # Dont allow randomize(undef, 'Laleh');
  if( (defined($_[1])) and (defined($_[0])) ) {
    $no_songs = shift(@_);
    $artist   = shift(@_);

    use App::Pimpd::Collection::Search;
    @songs = shuffle(search_db_artist($artist));
    @random = @songs[0 .. $no_songs -1];
  }
  else {
    $no_songs = shift(@_) // 100;
    @songs  = shuffle($mpd->collection->all_pathes);
    @random = (@songs[0 .. $no_songs - 1]);
  }
  return (wantarray()) ? @random : \@random;
}


sub randomize_albums {
  my $no_albums = shift // 10;
  my @albums = shuffle($mpd->collection->all_albums);

  my @songs;
  for(@albums) {
    if($no_albums == 0) {
      last;
    }
    my @songs_on_album = $mpd->collection->songs_from_album($_);
    if(scalar(@songs_on_album) <= 2) {
      next;
    }
    else {
      push(@songs, map { $_->file } @songs_on_album);
      $no_albums--;
    }
  }
  return (wantarray()) ? @songs : scalar(@songs);
}

sub random_track_in_playlist {
  if(empty_playlist()) {
    print STDERR "Playlist is empty - nothing to play\n";
    return 1;
  }
  my @items = $mpd->playlist->as_items;

  @items = shuffle(@items);

  return $items[0]->pos;
}


1;

__END__

=pod

=head1 NAME

App::Pimpd::Playlist::Randomize - Package exporting various randomizing functions

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Playlist::Randomize;

    my @random_songs = randomize(10);

    my @random_albums = randomize_albums(5);

    my $random_song = random_track_in_playlist();

=head1 DESCRIPTION

App::Pimpd::Playlist::Randomize provides functions for altering the current
playlist in random ways.

=head1 EXPORTS

=over

=item randomize()

  my @randoms = randomize(42);
  my $randoms = randomize();

Parameters: $integer, $artist

Returns:    @songs   | \@songs

In list context, returns a list with n random paths ( all relative to MPD ).
If a second argument is provided it's interpreted as an artist name. The list
will be crafted together with random paths from that artist.

In scalar context, returns an array reference.

If called with zero arguments, a default value of 100 totally random songs is
used.

=item random_albums();

  my @random_albums       = random_albums(42);
  my $random_albums_songs = random_albums();

Parameters: $integer | NONE

Returns:    @songs   | scalar(@songs)

In list context, returns a list with the paths to the songs of n random albums.

In scalar context, returns the number of B<songs> found on the n random albums.

If called with zero arguments, a default value of 10 albums is used.

=item random_track_in_playlist()

  my $position = random_track_in_playlist();
  $mpd->play($position);

Parameters: NONE

Returns:    $playlist_pos

Returns a valid playlist position id, used to reference a song in the playlist.

=back

=head1 SEE ALSO

App::Pimpd::Playlist

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
