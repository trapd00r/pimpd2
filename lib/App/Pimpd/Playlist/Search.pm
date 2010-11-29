#!/usr/bin/perl
package App::Pimpd::Playlist::Search;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(search_playlist);

use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;

use App::Pimpd;


sub search_playlist {
  my $query = shift // 'zelmani';

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

  #for my $pos(keys(%playlist)) {
  #  if($playlist{$pos} =~ /$query/gpi) {
  #    push(@result, $playlist{);
  #  }
  #}
  return (wantarray()) ? @result : scalar(@result);
}


1;
