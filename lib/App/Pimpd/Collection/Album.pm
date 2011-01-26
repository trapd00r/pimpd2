package App::Pimpd::Collection::Album;
use strict;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
    songs_on_album
    albums_by_artist
    delete_album
  );
}

use App::Pimpd;
use App::Pimpd::Validate;
use Term::ExtendedColor qw(fg);

sub delete_album {
  my $file = $mpd->current->file;

  my($path) = $file =~ m|(.+)/.+$|m;
  my @songs = $mpd->collection->all_items_simple($path);


  printf("Remove %s ? [y/N] ", fg('bold', $path));

  chomp(my $answer = <STDIN>);
  if(lc($answer) ne 'y') {
    return 1;
  }

  $path = "$config{music_directory}/$path";

  if(remote_host()) {
    open(OLD_STDOUT, '>&', STDOUT) or die("Cant dupe STDOUT: $!");
    close(STDOUT);
    system(
      'ssh', "-p $config{ssh_port}",
      "$config{ssh_user}\@$config{ssh_host}",
      "rm -rv '$path'",
    ) == 0 and do {
      open(STDOUT, '>&', OLD_STDOUT) or die("Cant reopen STDOUT: $!");
      printf("Removed %s successfully\n", fg('bold', $path));
      return;
    };
    open(STDOUT, '>&', OLD_STDOUT) or die("Cant reopen STDOUT: $!");

  }
  else {
    if(remove_path($path)) {
      printf("removed '%s'\n", fg('bold', $path));
      return;
    }
    print STDERR "remove_path($path): $!\n";
    return;
  }
  return;
}


sub albums_by_artist {
  my $artist = shift;
  if( (!defined($artist)) or ($artist eq '') ) {
    $artist = $mpd->current->artist;
  }

  return wantarray()
    ? sort($mpd->collection->albums_by_artist($artist))
    : scalar($mpd->collection->albums_by_artist($artist))
    ;
}

sub songs_on_album {
  my($album, $artist) = @_;
  #my $album  = shift // $mpd->current->album;
  #my $artist = shift // $mpd->current->artist;

  $album or $album = $mpd->current->album;
  if(!defined($album) or $album eq '') {
    print STDERR "Album tag missing!\n";
    return 1;
  }

  my @tracks;
  if($artist) {
  # We dont want _all_ albums named 'Best Of'.
  @tracks = grep { $_->artist eq $artist }
    $mpd->collection->songs_from_album($album);
  }
  else {
    @tracks = $mpd->collection->songs_from_album($album);
  }

  return (wantarray()) ? @tracks : scalar(@tracks);
}


1;

__END__

=pod

=head1 NAME

App::Pimpd::Collection::Album - Album functions

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Collection::Album;

    my @albums = albums_by_artist('Laleh');
    my @songs  = songs_on_album('Me and Simon');

=head1 DESCRIPTION

App::Pimpd::Collection::Album exports functions that provides album-specific data.

=head1 EXPORTS

=over

=item albums_by_artist()

  my @albums = albums_by_artist('Laleh');

Parameters: $artist | NONE

Returns:    @albums | scalar(@albums)

In list context, returns a sorted list with the albums (strings) where $artist is
featured.

In scalar context, returns the number of albums where $artist is featured.

If called without arguments, the current artist is used.

=item songs_on_album()

  my @songs =  songs_on_album('Stripped'); # Christina Aguilera

Parameters: $album, $artist | NONE

Returns:    @paths          | scalar(@paths)

In list context, returns a list with full paths to the songs on album.

In scalar context, returns the number of files on the album.

If called without arguments, the current album is used.

Note that if called without a second argument, it can return both Bob Dylan
and Britney Spears if the album is 'Best of'.

=back

=head1 SEE ALSO

App::Pimpd::Collection

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
