package App::Pimpd::Playlist::Search;
use strict;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
    search_playlist
    search_all_playlists
  );
}

use Carp;
use App::Pimpd;
use App::Pimpd::Validate;
use Term::ExtendedColor;


sub search_playlist {
  my $query = shift;

  if(!defined($query)) {
    confess("You must specify a query for search_playlist()");
  }

  if(invalid_regex($query)) {
    $query =~ s;^\Q;;;
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


sub search_all_playlists {
  my $query = shift;
  if(!defined($query)) {
    confess("You must specify a query for search_all_playlists()");
  }

  if(invalid_regex($query)) {
    $query =~ s;\Q;;;
  }

  my @matched_files;

  open(my $fh, '<', "$ENV{HOME}/.config/pimpd/fav.db")
    or print "No DB found\n" and return 1;
  chomp(my @tracks = <$fh>);

  for(@tracks) {
    if(invalid_regex($query)) {
      if($_ =~ /\Q$query/i) {
        push(@matched_files, $_);
      }
    }
    else {
      if($_ =~ /$query/i) {
        push(@matched_files, $_);
      }
    }
  }
  close($fh);
  return @matched_files;
}


1;

__END__


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

Parameters: $query

Returns:    \%result

Given a query (possibly a regular expression), return a hash whose keys are
the playlist position IDs and the values the paths (relative to MPD).

=item search_all_playlists()

Parameters: $query

Returns:    @paths

Given a query (possibly a regular expression), search through all playlists for
matches.

In list context, returns the matched paths.

In scalar context, returns the number of matched files.

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
