#!/usr/bin/perl
package App::Pimpd::Validate;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  invalid_regex
  to_terminal
  empty_playlist
  invalid_playlist_pos
);

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


=head3 invalid_regex()

  if(invalid_regex($regex)) {
    ...
  }

Returns true if the string supplied is not a valid regular expression.

=cut 

sub invalid_regex {
  my $re = shift;
  eval { qr/$re/ };
  if($@) {
    return 1;
  }
  else {
    return 0;
  }
}

=head3 to_terminal()

  if(to_terminal()) {
    ...
  }

Returns true if connected to a TTY.

=cut

sub to_terminal {
  return (-t STDOUT) ? 1 : 0;
}


sub empty_playlist {
  if(scalar($mpd->playlist->as_items) == 0) {
    return 1;
  }
  return 0;
}

sub invalid_playlist_pos {
  my @pos = @_;
  my @playlist = map { $_ = $_->pos } $mpd->playlist->as_items;
  my $fail = 0;

  for(@pos) {
    if($_ ~~ @playlist) {
      # all good
    }
    else {
      $fail++;
    }
  }
  return($fail);
}


1;
