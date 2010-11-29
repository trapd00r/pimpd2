#!/usr/bin/perl
package App::Pimpd;

use vars qw($VERSION);
$VERSION = 0.01;

require Exporter;
@ISA = 'Exporter';
our @EXPORT = qw($mpd);

use lib '/home/scp1/devel/pimpd-ng2/lib';

use Audio::MPD;
use Term::ExtendedColor;

our $mpd = Audio::MPD->new(
  host  => $ENV{MPD_HOST},
  port  => $ENV{MPD_PORT},
);




sub mpd_connect {
  $mpd;
}
