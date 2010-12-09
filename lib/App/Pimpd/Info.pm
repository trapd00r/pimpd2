#!/usr/bin/perl
package App::Pimpd::Info;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(current info);

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
use App::Pimpd::Validate;
use Term::ExtendedColor;

# NOTE To config
my $config_extended_colors = 1;
my $config_ansi_colors     = undef;


my(%current, %status, ,%stats);

sub _current_update {
  if($mpd->status->state ne 'stop') {
    %current = ('artist'     =>  $mpd->current->artist,
                   'album'      =>  $mpd->current->album,
                   'title'      =>  $mpd->current->title,
                   'genre'      =>  $mpd->current->genre,
                   'file'       =>  $mpd->current->file,
                   'date'       =>  $mpd->current->date,
                   'time'       =>  $mpd->status->time->sofar.'/'.
                                    $mpd->status->time->total,
                   'bitrate'    =>  $mpd->status->bitrate,
                   'audio'      =>  $mpd->status->audio,
                   );
    %status  = ('repeat'     =>  $mpd->status->repeat,
                   'shuffle'    =>  $mpd->status->random,
                   'xfade'      =>  $mpd->status->xfade,
                   'volume'     =>  $mpd->status->volume,
                   'state'      =>  $mpd->status->state,
                   'list'       =>  $mpd->status->playlist,
                   );
    %stats   = ('song'       =>  $mpd->status->song,
                   'length'     =>  $mpd->status->playlistlength,
                   'songs'      =>  $mpd->stats->songs,
                   'albums'     =>  $mpd->stats->albums,
                   'artists'    =>  $mpd->stats->artists,
                   );
  }
}

=head3 current()

  my $current = current();

Return a formatted string with relevant now playing information.

If $config_extended_colors is true, use 256 colors.

=cut

sub current {
  my $output;

  _current_update();

  if(not to_terminal()) {
    $config_extended_colors = 0;
    $config_ansi_colors     = 0;
  }

  if( ($config_extended_colors) or ($config_ansi_colors) ) {
    $output = sprintf("%s - %s on %s from %s [%s]",
      fg($c[3], fg('bold',  $current{artist})),
      fg($c[11], $current{title}),
      fg($c[0], $current{album}),
      fg($c[4], fg('bold', $current{date})),
      $current{genre},
    );
  }
  else {
    $output = sprintf("%s - %s on %s from %s [%s]",
      $current{artist},
      $current{title},
      $current{album},
      $current{date},
      $current{genre},
    );
  }

  return $output;
}

=head info()

  info();

Yields all available information.

=cut

sub info {
  (undef,undef,undef,undef,undef, my $crnt_year) = localtime(time);
  $crnt_year += 1900;

  _current_update();


  for(keys(%current)) {
    $current{$_} = fg($c[14], 'N/A') if(!defined($current{$_}));
  }

  $status{state} = 'Playing' if($status{state} eq 'play');
  $status{state} = 'Paused'  if($status{state} eq 'pause');
  $status{state} = 'Stopped' if($status{state} eq 'stop');

  if($status{volume} < 0) {
    $status{volume} = 'N/A (Software Mixer)';
  }

  printf("%s %8s: %.66s\n", fg('bold', fg('251', 'S')),
    'Artist', fg($c[3], fg('bold', $current{artist}))
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('250', 'O')),
    'Album', fg($c[0], $current{album})
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('249', 'N')),
    'Song', fg($c[11], fg('bold', $current{title}))
  );

  printf("%s %8s: %.66s\n", fg('bold', fg(248, 'G')),
    'Genre', fg($c[13], $current{genre})
  );
  printf("%s %9s: %s\n", fg('bold', undef),
    'File', fg($c[7], $current{file})
  );

  printf("%s %8s: %.66s\n", fg('bold', fg('247', 'I')),
    'Date', $current{date}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('246', 'N')),
    'Time', $current{time}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('245', 'F')),
    'Bitrate', $current{bitrate}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('244', 'O')),
    'Audio', $current{audio}
  );

  print fg($c[15]);
  print '-' x 25, clear(), "\n";

  printf("%s %8s: %.66s\n", fg('bold', fg('243', 'S')),
    'Repeat', $status{repeat}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('242', 'T')),
    'Shuffle', $status{shuffle}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('242', 'A')),
    'Xfade', $status{xfade}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('241', 'T')),
    'Volume', $status{volume}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('240', 'U')),
   'State', $status{state}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('239', 'S')),
   'List V', $status{list}
  );

  print fg($c[15]);
  print '-' x 25, clear(), "\n";

  printf("%s %8s: %.66s\n", fg('bold', fg('238', 'S')),
    'Song', $stats{song}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('237', 'T')),
    'List', $stats{length} . ' songs'
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('236', 'A')),
    'Songs', $stats{songs}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('235', 'T')),
    'Albums', $stats{albums}
  );
  printf("%s %8s: %.66s\n", fg('bold', fg('234', 'S')),
   'Artists', $stats{artists}
  );
}

=pod

=head1 NAME

App::Pimpd::Info

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Info;

    my $current = current();

    if( ... ) {
      info();
    }

=head1 DESCRIPTION

App::Pimpd::Info provides functions for displaying current playback information.

=head1 EXPORTS

=head2 current()

  my $current = current();

Returns a pre-formatted string holding info for the current song, on a single
line.

=head2 info()

  if( ... ) {
    info();
  }

Prints all available information for the current song and MPD server setup.

=head1 SEE ALSO

App::Pimpd

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
