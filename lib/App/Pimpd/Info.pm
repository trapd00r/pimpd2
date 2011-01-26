package App::Pimpd::Info;
use strict;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
    current
    info
  );
}

use App::Pimpd;
use App::Pimpd::Validate;
use Term::ExtendedColor qw(fg clear);

# FIXME
#get_color_support();


my(%current, %status, ,%stats);

sub _current_update {
  if($mpd->status->state ne 'stop') {
    %current = (
      'artist'     =>  $mpd->current->artist     // 'N/A',
      'album'      =>  $mpd->current->album      // 'N/A',
      'title'      =>  $mpd->current->title      // 'N/A',
      'genre'      =>  $mpd->current->genre      // 'N/A',
      'file'       =>  $mpd->current->file       // 'N/A',
      'date'       =>  $mpd->current->date       // 'N/A',
      'time'       =>  $mpd->status->time->sofar.'/'.
                       $mpd->status->time->total,
      'bitrate'    =>  $mpd->status->bitrate     // 'N/A',
      'audio'      =>  $mpd->status->audio       // 'N/A',
    );
    %status  = (
      'repeat'     =>  _on_off( $mpd->status->repeat ),
      'shuffle'    =>  _on_off( $mpd->status->random ),
      'xfade'      =>  _on_off( $mpd->status->xfade ),
      'volume'     =>  $mpd->status->volume,
      'state'      =>  $mpd->status->state,
      'list'       =>  $mpd->status->playlist,
    );
    %stats   = (
      'song'       =>  $mpd->status->song,
      'length'     =>  $mpd->status->playlistlength,
      'songs'      =>  $mpd->stats->songs,
      'albums'     =>  $mpd->stats->albums,
      'artists'    =>  $mpd->stats->artists,
    );
  }
  return;
}

sub current {
  _current_update();

  my $output;
  if(to_terminal()) {
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

sub info {
  (undef,undef,undef,undef,undef, my $crnt_year) = localtime(time);
  $crnt_year += 1900;

  _current_update();

  for(keys(%current)) {
    $current{$_} = fg($c[14], 'N/A') if(!defined($current{$_}));
  }

  $status{'state'} = 'Playing' if($status{'state'} eq 'play');
  $status{'state'} = 'Paused'  if($status{'state'} eq 'pause');
  $status{'state'} = 'Stopped' if($status{'state'} eq 'stop');

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
  return;
}

sub _on_off {
  my $state = shift;

  if($state > 1) {
    return "ON ($state)";
  }
  elsif($state == 1) {
    return 'ON';
  }
  return 'OFF';
}


1;

__END__

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

=over

=item current()

  my $current = current();

Returns a pre-formatted string holding info for the current song, on a single
line.

=item info()

  if( ... ) {
    info();
  }

Prints all available information for the current song and MPD server setup.

=back

=head1 SEE ALSO

App::Pimpd

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
