#!/usr/bin/perl
package App::Pimpd;

use vars qw($VERSION);
$VERSION = '0.10';


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
  $loved_database

  &get_color_support
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
  $loved_database,

  $c_extended_colors,
  $c_ansi_colors,

  $c_player,
  @c_player_opts,
  $c_player_url,
);

config_init();
mpd_init();
get_color_support();

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

sub get_color_support {
  if( not($c_extended_colors) and not($c_ansi_colors) ) {
    # Clear the color array.
    @c = ();
    return 0;
  }
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
  if(-e "$ENV{HOME}/.config/pimpd2/pimpd2.conf") {
    $config = "$ENV{HOME}/.config/pimpd2/pimpd2.conf";
  }
  elsif(-e "$ENV{HOME}/.pimpd2.conf") {
    $config = "$ENV{HOME}/.pimpd2.conf";
  }
  elsif(-e "$ENV{HOME}/pimpd2.conf") {
    $config = "$ENV{HOME}/pimpd2.conf";
  }
  elsif(-e './pimpd2.conf') {
    $config = './pimpd2.conf';
  }
  elsif(-e '/etc/pimpd2.conf') {
    $config = '/etc/pimpd2.conf';
  }
  else {
    warn "No configuration file found.\n";
    warn "See docs/pimpd2.conf.example for an example configuration file.\n";
    exit 1;
  }
  #print "Config found: $config\n";

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

=over

=item $mpd

The base object used to communicate with mpd.

=item $mpd_host, $mpd_port, $mpd_user, $mpd_pass

MPD connection details, grabbed from environment variables and/or configuration
file.

=item $ssh_host, $ssh_port, $ssh_user

SSH connection details. Used in B<App::Pimpd::Transfer>.

=item $music_directory, $playlist_directory

As specified in mpd.conf

=item $target_directory

The directory where B<App::Pimpd::Transfer> will place all files.

=item @c

List of colors, from configuration file.

Contains valid arguments to B<Term::ExtendedColor>, like so:

    $c[0]  = 'red2';
    $c[1]  = 'blue4';
    $c[2]  = 'green14';

    ...

    $c[15] = 'purple3';

=back

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
