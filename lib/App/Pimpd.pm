#!/usr/bin/perl
package App::Pimpd;

use vars qw($VERSION);
$VERSION = 0.06;

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

App::Pimpd - Base class for pimpd2

=head1 SYNOPSIS

    use App::Pimpd;

    $\ = "\n";
    print $mpd_host;
    print $mpd_port;

=head1 DESCRIPTION

B<App::Pimpd> is the base class for the rest of the App::Pimpd namespace, exporting
the $mpd object and a couple of configuration variables.


=head1 EXPORTS

=head2 $mpd

The base object used to communicate with mpd.

=head2 $mpd_host, $mpd_port, $mpd_user, $mpd_pass

MPD connection details, grabbed from environment variables and/or configuration
file.

=head2 $ssh_host, $ssh_port, $ssh_user

SSH connection details. Used in B<App::Pimpd::Transfer>.

=head2 $music_directory, $playlist_directory

As specified in mpd.conf

=head2 $target_directory

The directory where B<App::Pimpd::Transfer> will place all files.

=head2 @c

List of colors, from configuration file.

Contains valid arguments to B<Term::ExtendedColor>, like so:

    $c[0]  = 'red2';
    $c[1]  = 'blue4';
    $c[2]  = 'green14';

    ...

    $c[15] = 'purple3';


=head1 SEE ALSO

B<Term::ExtendedColor>

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
