package App::Pimpd;
use strict;
use encoding 'utf8';
use open qw(:utf8 :std);

BEGIN {
  use Exporter;
  use vars qw($VERSION @ISA @EXPORT);

  $VERSION = '0.302';
  @ISA = qw(Exporter);
  @EXPORT = qw(
    @c
    $mpd
    %config

    &get_color_support
    &player_cmdline
    &abs_playlist_path
  );
}

use Audio::MPD;
use Config::General;
use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;

our ($mpd, %config, @c);

# Load the configuration file and fill %config with keys and values
config_init();
# Initialize the connection to the MPD server
mpd_init();

#get_color_support();

sub player_cmdline {
  if(exists($config{player})) {
    if(!exists($config{player_stream})) {
      #chomp($config{player_stream} = <STDIN>);
      print STDERR "No remote MPD adress specified in pimpd.conf. Exiting...\n";
      return 1;
    }
    return "$config{player} $config{player_stream} $config{player_opts}";
  }
  print STDERR "No player configured\n";
  return 1;
}

#sub get_color_support {
#  if( not($c_extended_colors) and not($c_ansi_colors) ) {
#    # Clear the color array.
#    @c = ();
#    return 0;
#  }
#}

sub mpd_init {
  my($host, $port, $password) = @_;
  if(defined($host)) {
    $mpd = Audio::MPD->new(
      host     => $host,
      port     => $port,
      password => $password,
    );
    return;
  }

  if( (exists($config{mpd_host})) or (exists($config{mpd_port})) ) {
    if( (exists($config{mpd_pass}))
        and ($config{mpd_pass} ne '')
        and ($config{mpd_pass} ne "''")
        and ($config{mpd_pass} ne '""')
    ) {
      $mpd = Audio::MPD->new(
        host      => $config{mpd_host},
        port      => $config{mpd_port},
        password  => $config{mpd_pass},
      );
    }
    else {
      $mpd = Audio::MPD->new(
        host      => $config{mpd_host},
        port      => $config{mpd_port},
      );
    }
  }
  return;
}

sub abs_playlist_path {
  my $list = shift;
  return $config{playlist_directory} . "/$list.m3u";
  #unless(!App::Pimpd::Validate::isa_valid_playlist($list));
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

  my $conf = Config::General->new(
    '-ConfigFile'        => $config,
    '-AllowMultiOptions' => 1,
    '-LowerCaseNames'    => 1,
    '-AutoTrue'          => 1,
    #'-DefaultConfig'     => \%default_config,
    '-InterPolateEnv'    => 1,
    'CComments'          => 1,
  );

  %config = $conf->getall;
  $config{_filename} = $config;

  for my $color( sort grep{ /color/m } keys(%config) ) {
    # color0 => green8
    # color1 => purple14
    push(@c, $config{$color});
  }
  return;
}


1;

__END__

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

Copyright (C) 2010, 2011 Magnus Woldrich. All right reserved.
This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
