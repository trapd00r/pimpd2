#!/usr/bin/perl
package App::Pimpd::Playlist::Favorite;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  add_to_favlist
);

use strict;

use App::Pimpd;
use App::Pimpd::Validate;
use Term::ExtendedColor;

sub add_to_favlist {
  my $favlist_m3u = shift; # arbitary playlist name
  my $artist = $mpd->current->artist // 'undef';
  my $album  = $mpd->current->album  // 'undef';
  my $title  = $mpd->current->title  // 'undef';
  my $genre  = $mpd->current->genre  // 'undef';
  my $file   = $mpd->current->file;
  #my $file   = $basedir . '/' . $mpd->current->file;

  $genre =~ s/\s+/_/g; # evil whitespace

  my(undef, undef, undef, undef, $month, $year) = localtime(time);
  $month += 1;
  $year  += 1900;

  if($favlist_m3u) {
    $favlist_m3u = "$playlist_directory/" . $favlist_m3u . '.m3u';
  }
  else {
    # 2010-12-rock.m3u
    $favlist_m3u = $playlist_directory . "/"
      . sprintf("%d-%02d-%s.m3u", $year, $month, lc($genre));
  }

  if(remote_host()) {
    # Sometimes this yells 'Illegal seek at [ ... ].
    # No idea why. It works anyway. Lets fail silently here until
    # we find a proper solution.

    system('ssh', ('-p', $ssh_port, "$ssh_user\@$ssh_host",
                         "echo '$file' >> $favlist_m3u",
                       ),
    ) == 0 and do {
      printf("'%s' >> %s:%s\n", 
        fg($c[3], $title), fg('bold', $ssh_host), fg($c[4], $favlist_m3u),
      );
      return 0;
    };
    return 1;
  } # Nope, not remote

  open(my $fh, '>>', $favlist_m3u)
    or die("Could not open '$favlist_m3u' in append mode: $!");
  print $fh "$file\n";
  close($fh);

  print fg($c[8], fg('bold', $title)), ' => ', fg($c[6], $favlist_m3u), "\n";
}

=pod

=head1 NAME

App::Pimpd::Playlist::Favorite - Package exporting functions for the favlist
functionality

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Playlist::Favorite;

    if($mpd->current->title eq 'This song is awesome!') {
      add_to_favlist();
    }

=head1 DESCRIPTION

App::Pimpd::Playlist::Favorite exports functions dealing with the favlist
functionality.

=head1 EXPORTS

=head2 add_to_favlist()

Parameters: $playlist_name | NONE

Saves the currently playing song to a special playlist, 'favlist'.

If called without arguments, the playlist naming template is
C<%year-%month-%genre>, else the argument is used.

=head1 SEE ALSO

App::Pimpd::Playlist

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



1;
