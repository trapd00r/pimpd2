#!/usr/bin/perl
package App::Pimpd::Collection::Search;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(search_db);

use App::Pimpd qw($mpd);
use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;


sub search_db {
  my $query = shift;

  my @result;
  for($mpd->collection->all_pathes) {
    if($_ =~ /$query/i) {
      push(@result, $_);
    }
  }
  return (wantarray()) ? @result : scalar(@result);
}


1;
