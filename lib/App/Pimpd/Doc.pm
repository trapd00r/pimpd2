#!/usr/bin/perl
package App::Pimpd::Doc;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  help
);

use strict;
use App::Pimpd;
use Term::ExtendedColor;

sub help {
  my $cmd = shift;

  my %help = (
    randomize   => \&_help_randomize,
    randomalbum => \&_help_randomize_albums,
  );

  if(defined($help{$cmd})) {
    $help{$cmd}->();
  }
  else {
    print "No such topic.\n";
  }
}

sub _help_randomize {
  return << "EOF"

@{[fg('bold', 'Usage')]}: randomize [INTEGER] [ARTIST]

Add n random songs from the collection to the current playlist.

The first, optional argument, is the number of songs to add.
The second, optional argument, is an artist name.
If a second argument is provided, add n random songs from that artist.

Defaults to 100 random songs.

EOF
}

sub _help_randomize_albums {
return << "EOF"

@{[fg('bold', 'Usage')]}: randomalbum [INTEGER]

Add n random full albums to the current playlist.

Defaults to 10 albums.

EOF
}
