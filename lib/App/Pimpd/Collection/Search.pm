#!/usr/bin/perl
package App::Pimpd::Collection::Search;

use vars qw($VERSION);
$VERSION = 0.10;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  search_db_quick
  search_db_artist
  search_db_album
  search_db_title
  );

use strict;
use App::Pimpd;
use App::Pimpd::Validate;
use Carp 'confess';


sub search_db_quick {
  my $query = shift;

  if(invalid_regex($query)) {
    confess("Invalid regex: '$query'");
  }

  my @result;
  for($mpd->collection->all_pathes) {
    if($_ =~ /$query/i) {
      push(@result, $_);
    }
  }
  return (wantarray()) ? @result : scalar(@result);
}

sub search_db_artist {
  my $artist  = shift; # Not a regex

  my @tracks = $mpd->collection->songs_by_artist_partial($artist);

  if(!@tracks) {
    return "0";
  }

  map{ $_ = $_->file } @tracks;

  return (wantarray()) ? @tracks : scalar(@tracks);
}

sub search_db_title {
  my $title  = shift;
  my @titles = $mpd->collection->songs_with_title_partial($title);

  if(!@titles) {
    return "0";
  }

  map{ $_ = $_->file } @titles;

  return (wantarray()) ? @titles : scalar(@titles);
}

sub search_db_album {
  my $album  = shift;
  my @albums = $mpd->collection->songs_from_album_partial($album);

  if(!@albums) {
    return "0";
  }
  map { $_ = $_->file } @albums;

  return (wantarray()) ? @albums : scalar(@albums);
}

=pod

=head1 NAME

App::Pimpd::Collection::Search - Package exporting various search functions for
the MPD collection

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Collection::Search

    my @album  = search_db_album('Stripped');
    my @songs  = search_db_quick('love');

=head1 DESCRIPTION

App::Pimpd::Collection::Search provides search functions for the MPD collection

=head1 EXPORTS

=head2 search_db_quick()

  my @paths = search_db_quick('foo');

Parameters: $regex

Returns:    @paths

Given a valid regular expression, searches the collection for matching
filenames. The search is performed case insensitive.

In list context, returns full paths for the matched songs.

In scalar context, returns the number of matches.

=head2 search_db_artist()

  my @paths = search_db_artist('Laleh');

Parameters: $string

Returns:    @paths

In list context, returns full paths for all songs by $artist.

In scalar context, returns the number of songs by $artist.

=head2 search_db_album()

Parameters: $string

Returns:    @paths

In list context, returns full paths for the songs on $album.

In scalar context, returns the number of songs on albums.

=head2 search_db_title()

Parameters: $string

Returns:    @paths

In list context, returns full paths for the songs named $string.

In scalar context, returns the number of songs named $string.

=head1 SEE ALSO

App::Pimpd::Collection

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
