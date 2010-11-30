#!/usr/bin/perl
package App::Pimpd::Playlist::Search;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(search_playlist);

use strict;
use Carp;
use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;

use App::Pimpd;
use App::Pimpd::Validate;


=head3 search_playlist()

  my $results = search_playlist($search_str);
  print Dumper $results;

Returns a hashref with the numeric pos id as key and the filename for value.

=cut

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


1;
