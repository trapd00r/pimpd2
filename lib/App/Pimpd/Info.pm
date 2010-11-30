#!/usr/bin/perl
package App::Pimpd::Info;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(current);

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
use Term::ExtendedColor;

my $config_extended_colors = 1;


=head3 current()

  my $current = current();

Return a formatted string with relevant now playing information.

If $config_extended_colors is true, use 256 colors.

=cut

sub current {
  my $artist = $mpd->current->artist // 'undef';
  my $album  = $mpd->current->album  // 'undef';
  my $title  = $mpd->current->title  // 'undef';
  my $genre  = $mpd->current->genre  // 'undef';
  my $date   = $mpd->current->date   // 'undef';

  my $output;
  if(defined($config_extended_colors)) {
    $output = sprintf("%s - %s on %s from %s [%s]", 
      fg('green27', fg('bold',  $artist)),
      fg('yellow5', $title), fg('blue4', $album),
      fg('orange2', fg('bold', $date)),
      $genre,
    );
  }

  return $output;
}



1;
