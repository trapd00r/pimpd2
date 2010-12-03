#!/usr/bin/perl
package App::Pimpd;

use vars qw($VERSION);
$VERSION = 0.01;

my $config;
BEGIN {
  $config = '/home/scp1/devel/pimpd-ng2/pimpd.conf';
  require($config);
}

require Exporter;
@ISA = 'Exporter';
our @EXPORT = qw(
  $mpd
  @c
  $mpd_host
  $mpd_port
  $mpd_pass
  $mpd_user
  $ssh_host
  $ssh_port
  $ssh_user

  $music_directory
  $playlist_directory
  $target_directory
);

use lib '/home/scp1/devel/pimpd-ng2/lib';

use strict;
use Audio::MPD;

our $mpd = Audio::MPD->new(
  host  => $ENV{MPD_HOST},
  port  => $ENV{MPD_PORT},
);

our(
  @c,
  $mpd_host,
  $mpd_port,
  $mpd_pass,
  $mpd_user,

  $ssh_host,
  $ssh_port,
  $ssh_user,

  $music_directory,
  $playlist_directory,
);






=pod

=head1 NAME

pimpd2 - Perl Interface for the Music Player Daemon 2

=head1 SYNOPSIS

=head3 Usage

  pimpd2 [OPTION] [FILE...]

=head1 DESCRIPTION

pimpd rocks

=head1 OPTIONS

=head1 AUTHOR

Written by Magnus Woldrich

=head1 REPORTING BUGS

Report bugs to trapd00r@trapd00r.se

=head1 COPYRIGHT

Copyright (C) 2010 Magnus Woldrich

License GPLv2

=cut

1;
