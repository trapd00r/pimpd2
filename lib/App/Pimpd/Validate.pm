#!/usr/bin/perl
package App::Pimpd::Validate;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(
  invalid_regex
  to_terminal
  empty_playlist
  invalid_playlist_pos
  remote_host
  escape
  get_valid_lists
);

use lib '/home/scp1/devel/pimpd-ng2/lib';

use strict;
use App::Pimpd;
use Term::ExtendedColor;


=pod

=head1 NAME

App::Pimpd::Validate

=cut

sub get_valid_lists {
  my @lists       = @_;
  my @valid_lists = sort($mpd->collection->all_playlists);

  for my $list(@lists) {
    if($list ~~ @valid_lists) {
      next;
    }
    else {
      my @choices = ();

      for my $valid(@valid_lists) {
        if($valid =~ /$list/i) {
          push(@choices, $valid);
        }
      }
      if(scalar(@choices) == 0) {
        print STDERR "No such playlist '" . fg($c[5], $list), "'\n";
        return;
      }

      my $i = 0;
      for my $choice(@choices) {
        print fg('bold', sprintf("%3d", $i)), " $choice\n";
        $i++;
      }
      print "choice: ";
      chomp(my $answer = <STDIN>);

      if($answer eq 'all') {
        return(@choices); # return all matched lists
      }
      elsif($answer eq 'current') {
        return(undef);
      }
      if($answer ~~ @valid_lists) {
        $list = $answer;
      }
      # Make sure the number selected is in fact valid
      elsif($answer >= 0 and $answer <= scalar(@valid_lists)) {
        $list = $choices[$answer];
      }
      else {
        print STDERR "Playlist $answer is not valid\n";
        return 1;
      }
    }
  }
  return(@lists);
}



=head2 escape()

  my $str = escape('fo&oba|r\n');

Returns the argument in a shape that's safe for the shell.

=cut

sub escape {
  my $str = shift;
  $str =~ s/([;<>\*\|`&\$!#\(\)\[\]\{\}:'"])/\\$1/g;

  return $str;
}

=head2 remote_host()

  if(remote_host()) {
    ...
  }

Returns true if a remote host is specified that does not match 'localhost' or
127.0.0.1

=cut

sub remote_host {
  not defined($mpd_host) and $mpd_host = 'localhost';
  if( ($mpd_host eq 'localhost') or ($mpd_host eq '127.0.0.1')) {
    return 0;
  }
  return 1;
}


=head2 invalid_regex()

  if(invalid_regex($regex)) {
    ...
  }

Returns true if the string supplied is not a valid regular expression.

=cut

sub invalid_regex {
  my $re = shift;
  eval { qr/$re/ };
  if($@) {
    return 1;
  }
  else {
    return 0;
  }
}

=head2 to_terminal()

  if(to_terminal()) {
    ...
  }

Returns true if connected to a TTY.

=cut

sub to_terminal {
  return (-t STDOUT) ? 1 : 0;
}

=head2 empty_playlist()

  if(empty_playlist()) {
    ...
  }

Returns true if the playlist is empty.

=cut

sub empty_playlist {
  if(scalar($mpd->playlist->as_items) == 0) {
    return 1;
  }
  return 0;
}

=head2 invalid_playlist_pos()

  if(invalid_playlist_pos(@list)) {
    ...
  }

Returns true if any of the supplied playlist IDs is invalid.

=cut

sub invalid_playlist_pos {
  my @pos = @_;
  my @playlist = map { $_ = $_->pos } $mpd->playlist->as_items;
  my $fail = 0;

  for(@pos) {
    if($_ ~~ @playlist) {
      # all good
    }
    else {
      $fail++;
    }
  }
  return($fail);
}


1;
