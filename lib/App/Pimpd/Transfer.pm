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
    return scp($file, $destination);
    print "REMOTE";
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

sub scp {
  my($source, $dest) = @_;

  # FIXME let scp's fail
  system('scp', '-r',  "-P $ssh_port", "$ssh_host:'$source'", $dest)
    == 0 or confess("scp: $!");
}




1;
