#!/usr/bin/perl
package App::Pimpd::Playlist::Search;

use vars qw($VERSION);
$VERSION = 0.10;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(search_playlist);

use strict;
use Carp;

use App::Pimpd;
use App::Pimpd::Validate;


sub search_playlist {
  my $query = shift;

  if(!defined($query)) {
    confess("You must specify a query for search_playlist()");
  }

  if(invalid_regex($query)) {
    confess("Invalid regex '$query'");
  }

  my %result;
  for($mpd->playlist->as_items) {
    my $str = join(' - ', $_->artist, $_->album, $_->title);
    if($str =~ /$query/gpi) {
      $result{$_->pos} = $_->file;
    }
  }

  return \%result;
}

=pod

=head1 NAME

App::Pimpd::Playlist::Search - Search the current playlist

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Playlist::Search

    my $result = search_playlist('laleh');

    my $file = $result->{42};

=head1 DESCRIPTION

App::Pimpd::Playlist::Search provides functions for searching the current
playlist.

=head1 EXPORTS

=over

=item search_playlist()

Parameters: $regex

Returns:    \%position_and_files

Build up a hash where the playlist position IDs are mapped to the filenames.

The result is returned as a hash reference.

=pod

=head1 SEE ALSO

App::Pimpd::Playlist

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

