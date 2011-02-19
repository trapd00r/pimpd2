package App::Pimpd::Playlist::Favorite;
use strict;
use encoding 'utf8';
use open qw(:utf8 :std);

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);

  @ISA         = qw(Exporter);
  @EXPORT      = qw(
    add_to_favlist
    already_loved
    search_favlist
    remove_favorite
  );
}


use Carp 'confess';
use App::Pimpd;
use App::Pimpd::Validate;
use Term::ExtendedColor qw(fg bg);
use Tie::File;

sub already_loved {
  my($file, $playlist) = @_;

  my $fh;
  # Ok, we have not specified an arbitary playlist name, let's see if this
  # song have been loved yet!
  if(!defined($playlist)) {
    open($fh, '<', $config{loved_database})
      or confess("Cant open '$config{loved_database}': $!");
  }

  # See if the song is loved in the arbitary playlist
  else {
    if(isa_valid_playlist($playlist)) {
      open($fh, '<', "$config{playlist_directory}/$playlist.m3u")
        or confess("Can not open $config{playlist_directory}/$playlist: $!");
    }
    else {
      return;
    }
  }

  chomp(my @songs = <$fh>);
  close($fh);

  return ($file ~~ @songs) ? 1 : 0;
}


sub remove_favorite {
  my $query = shift;
  return if !defined($query);

  tie(my @songs, 'Tie::File', $config{loved_database})
    or confess("Cant TIE '$config{loved_database}': $!");
  my $i = 0;
  for my $s(@songs) {
    if($s =~ m/$query/i) {
      my $old = $songs[$i];
      if(splice(@songs,$i, 1)) {
        printf("%s removed from favlist\n", $old);
      }
      else {
        die("Cant remove $songs[$i]: $!\n");
      }
    }
    $i++;
  }
  untie(@songs) or confess("Cant close $config{loved_database}: $!");
  return;
}

sub search_favlist {
  my $query = shift;

  open(my $fh, '<', $config{loved_database})
    or confess("Cant open '$config{loved_database}': $!");
  chomp(my @songs = <$fh>);
  close($fh);

  if(!defined($query)) {
    print "$_\n" for sort(@songs);
    return;
  }

  my @results;
  for(@songs) {
    if(invalid_regex($query)) {
      if($_ =~ m/\Q$query/im) {
        push(@results, $_);
      }
    }
    else {
      if($_ =~ m/$query/im) {
        push(@results, $_);
      }
    }
  }

  return (wantarray()) ? @results : scalar(@results);
}



sub add_to_favlist {
  my $favlist_m3u = shift; # arbitary playlist name

  my $artist = $mpd->current->artist // 'undef';
  my $album  = $mpd->current->album  // 'undef';
  my $title  = $mpd->current->title  // 'undef';
  my $genre  = $mpd->current->genre  // 'undef';
  my $file   = $mpd->current->file;
  #my $file   = $basedir . '/' . $mpd->current->file;

  # Do not complain if an arbitary playlist name is specified.
  if(!defined($favlist_m3u)) {
    if(already_loved($file)) {
      printf("%s by %s is already loved!\n",
        fg($c[11], $title), fg($c[2], $artist),
      );

      return;
    }
  }
  else {
    if(already_loved($file, $favlist_m3u)) {
      printf("%s by %s is already loved in %s\n",
        fg($c[11], $title), fg($c[2], $artist), fg('bold', $favlist_m3u),
      );
      return;
    }
  }


  $genre =~ s/\s+/_/gm; # evil whitespace

  my(undef, undef, undef, undef, $month, $year) = localtime(time);
  $month += 1;
  $year  += 1900;

  if($favlist_m3u) {
    $favlist_m3u = "$config{playlist_directory}/" . $favlist_m3u . '.m3u';
  }
  else {
    # 2010-12-rock.m3u
    $favlist_m3u = $config{playlist_directory} . "/"
      . sprintf("%d-%02d-%s.m3u", $year, $month, lc($genre));
  }

  # Write the db locally.
  open(my $fh, '>>', $config{loved_database})
    or confess("Cant open '$config{loved_database}': $!");
  print $fh "$file\n";
  close($fh);

  if(remote_host()) {
    # Sometimes this yells 'Illegal seek at [ ... ].
    # No idea why. It works anyway. Lets fail silently here until
    # we find a proper solution.

    system('ssh',
      ('-p', $config{ssh_port},
        "$config{ssh_user}\@$config{ssh_host}", "echo '$file' >> $favlist_m3u",
      ),
    ) == 0 and do {
      printf("'%s' >> %s:%s\n",
        fg($c[3], $title),
        $config{ssh_host},
        fg($c[4], $favlist_m3u),
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

  return;
}


1;

__END__

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

=over

=item add_to_favlist()

Parameters: $playlist_name | NONE

Saves the currently playing song to a special playlist, 'favlist'.

If called without arguments, the playlist naming template is
C<%year-%month-%genre>, else the argument is used.

=back

=head1 SEE ALSO

App::Pimpd::Playlist

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
