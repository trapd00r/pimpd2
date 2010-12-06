#!/usr/bin/perl
package App::Pimpd::Collection::Search;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  search_db_quick
  search_db_artist
  search_db_album
  search_db_title
  );

use strict;
use App::Pimpd qw($mpd);
use Carp 'confess';
use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;


=pod

=head1 NAME

App::Pimpd::Collection::Search - search the MPD collection

=head2 search_db_quick()

  my @files = search_db_quick($query);
  my $finds = search_db_quick($query);

In list context, returns all files matching pattern.
In scalar context, returns the number of matches.

=cut

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

=head2 search_db_artist()

  my @artists = search_db_artist($artist);

In list context, returns all files where the artist fields partially matches
str.

In scalar context, returns the number of finds.

=cut

sub search_db_artist {
  my $artist  = shift; # Not a regex

  my @tracks = $mpd->collection->songs_by_artist_partial($artist);

  if(!@tracks) {
    return "0";
  }

  map{ $_ = $_->file } @tracks;

  return (wantarray()) ? @tracks : scalar(@tracks);
}

=head2 search_db_title()

  my @titles = search_db_title($title);

In list context, returns all files where the title fields partially matches
str.

In scalar context, returns the number of finds.

=cut

sub search_db_title {
  my $title  = shift;
  my @titles = $mpd->collection->songs_with_title_partial($title);

  if(!@titles) {
    return "0";
  }

  map{ $_ = $_->file } @titles;

  return (wantarray()) ? @titles : scalar(@titles);
}

=head2 search_db_album()

  my @albums = search_db_album($album);

In list context, returns all files where the album fields partially matches
str.

In scalar context, returns the number of finds.

=cut

sub search_db_album {
  my $album  = shift;
  my @albums = $mpd->collection->songs_from_album_partial($album);

  if(!@albums) {
    return "0";
  }
  map { $_ = $_->file } @albums;

  return (wantarray()) ? @albums : scalar(@albums);
}




1;
