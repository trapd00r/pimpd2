#!/usr/bin/perl
package App::Pimpd::Collection::Search;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(search_db_quick);

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


sub search_db {
  my $query = shift;

  if(!defined($query)) {
    return undef;
  }

  if(invalid_regex($query)) {
    confess("Invalid regex '$query'");
  }

  my @result;

  my %playlist;
  for($mpd->playlist->as_items) {
    $playlist{pos}{$_->pos} = join(' - ', $_->artist, $_->album, $_->title);
  }
  #print Dumper \%playlist;

  for my $pos(keys(%{$playlist{pos}})) {
    if($playlist{pos}->{$pos} =~ /$query/pig) {
      push(@result, $pos);
    }
  }
  return (wantarray()) ? @result : scalar(@result);
}


1;
sub search_db_quick {
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
