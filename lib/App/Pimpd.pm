#!/usr/bin/perl
package App::Pimpd;

use vars qw($VERSION);
$VERSION = 0.01;

require Exporter;
@ISA = 'Exporter';
our @EXPORT = qw($mpd @c);

use lib '/home/scp1/devel/pimpd-ng2/lib';

use strict;
use Audio::MPD;

our $mpd = Audio::MPD->new(
  host  => $ENV{MPD_HOST},
  port  => $ENV{MPD_PORT},
);

our @c;

my $config = './pimpd.conf';
require($config);

#!/usr/bin/perl
our $APP     = undef;
our $VERSION = '0.1.0';
use strict;
use Data::Dumper;
use Pod::Usage;






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

