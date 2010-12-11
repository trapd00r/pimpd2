#!/usr/bin/perl
package App::Pimpd;

use vars qw($VERSION);
$VERSION = 0.10;


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

  &color_support
  &player_cmdline

);

use strict;
use Audio::MPD;

our $mpd;

# From configuration file
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

  $c_extended_colors,
  $c_ansi_colors,

  $c_player,
  @c_player_opts,
  $c_player_url,
);

config_init();
mpd_init();

sub player_cmdline {
  if(defined($c_player)) {
    if(!defined($c_player_url)) {
      print STDERR "No remote MPD adress specified in pimpd.conf. Exiting...\n";
      return 1;
    }
    return "$c_player $c_player_url @c_player_opts";
  }
  print STDERR "No player configured\n";
  return 1;
}

sub color_support {
  if($c_extended_colors) {
    return 256;
  }
  elsif($c_ansi_colors) {
    return 16;
  }

  # Clear the color array.
  @c = ();
  return 0;
}

sub mpd_init {
  if( (defined($mpd_host)) or (defined($mpd_port)) ) {
    $mpd = Audio::MPD->new(
      host  => $mpd_host,
      port  => $mpd_port,
    );
  }
}

sub config_init {
  my $config;
  if(-e "$ENV{HOME}/.config/pimpd2/pimpd.conf") {
    $config = "$ENV{HOME}/.config/pimpd2/pimpd.conf";
  }
  elsif(-e "$ENV{HOME}/.pimpd.conf") {
    $config = "$ENV{HOME}/.pimpd.conf";
  }
  elsif(-e "$ENV{HOME}/pimpd.conf") {
    $config = "$ENV{HOME}/pimpd.conf";
  }
  elsif(-e './pimpd.conf') {
    $config = './pimpd.conf';
  }
  elsif(-e '/etc/pimpd.conf') {
    $config = '/etc/pimpd.conf';
  }
  else {
    print STDERR "No configuration file found\n";
    return 1;
  }

  require($config);
  warn $@ if $@;
}

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
