package App::Pimpd::Transfer;
use strict;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
    cp
    cp_album
    cp_list
  );
}

use Carp qw(confess);
use File::Copy;
use App::Pimpd;
use App::Pimpd::Validate;

sub cp_album {
  my $destination = shift;

  my $album   = $mpd->current->album;
  my $artist  = $mpd->current->artist;

  my @tracks = grep {
    $artist eq $_->artist
  } $mpd->collection->songs_from_album($album);;

  @tracks = map { $config{music_directory} . '/' . $_->file } @tracks;

  if(remote_host()) {
    for(@tracks) {
      #$_ = escape($_);
      _scp($_, $destination);
    }
  }

  else {
    for(@tracks) {
      $_ = escape($_);
      if(copy($_, $destination)) {
        printf("%40.40s => %s\n", $_, $destination);
      }
      else {
        warn("cp_album: $!");
      }
    }
  }
  return;
}

sub cp {
  my $destination = shift;
  #is_existing_dir($destination); # FIXME

  if(empty_playlist()) {
    return 1;
  }

  my $file; # = $mpd->current->file;
  if($config{music_directory} =~ m|.+/$|m) {
    $file = $config{music_directory} .= $mpd->current->file;
  }
  else {
    $file = $config{music_directory} . '/' . $mpd->current->file;
  }

  if(remote_host()) {
    return _scp($file, $destination);
  }

  else {
    $file = escape($file);
    if(copy($file, $destination)) {
      return 1;
    }
    else {
      confess("cp: $!");
    }
  }
  return;
}

sub _scp {
  my($source, $dest) = @_;

  system('scp', '-r',
    "-P $config{ssh_port}",
    "$config{ssh_host}:'$source'", $dest
  ) == 0 or confess("scp: $!");

  return;
}


1;

__END__

=pod

=head1 NAME

App::Pimpd::Transfer

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Transfer;

    cp('/tmp');
    cp_album();

=head1 DESCRIPTION

App::Pimpd::Transfer provides functions for transfering music from the MPD
server to the local machine.

=head1 EXPORTS

=over

=item cp()

  cp($location);

Parameters: $path | NONE

Copy the currently playing song to B<$location>. If $location is omitted, uses
the B<target_directory> variable from the configuration file.

=item cp_album()

  cp_album($location);

Parameters: $path | NONE

Copy the songs from the currently playing album to $location. If $location is 
omitted, uses the target_directory variable from the configuration file.

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
