#!/usr/bin/perl
package App::Pimpd::Transfer;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  cp
  cp_album
  cp_list
);

use lib '/home/scp1/devel/pimpd-ng2/lib';

use strict;
use Carp;
use File::Copy;

use App::Pimpd;
use App::Pimpd::Validate;

=pod

=head1 NAME

App::Pimpd::Transfer - transfer remote/local music files elsewhere

=head2 cp_album()

  cp_album($destination);

If we're dealing with a local MPD server, copy all tracks from the current album
to the defined destination.

If the MPD server is on a remote box, we use scp. The reason why we're not using
Net::SCP is because it's no more then a simple wrapper around the scp binary
anyway.

=cut

sub cp_album {
  my $destination = shift;

  my $album  = $mpd->current->album;

  my @tracks = map {
    $music_directory . '/' . $_->file
    } $mpd->collection->songs_from_album($album);


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
}

=head2 cp()

  cp($destination);

Copy the current track to destination.

=cut

sub cp {
  my $destination = shift;
  #is_existing_dir($destination); # FIXME

  if(empty_playlist()) {
    return 1;
  }

  my $file; # = $mpd->current->file;
  if($music_directory =~ m|.+/$|) {
    $file = $music_directory .= $mpd->current->file;
  }
  else {
    $file = "$music_directory/" . $mpd->current->file;
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
}

sub _scp {
  my($source, $dest) = @_;

  # FIXME let scp's fail
  system('scp', '-r',  "-P $ssh_port", "$ssh_host:'$source'", $dest)
    == 0 or confess("scp: $!");
}




1;
