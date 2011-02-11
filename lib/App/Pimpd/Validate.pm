package App::Pimpd::Validate;
use strict;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
    invalid_regex
    to_terminal
    empty_playlist
    invalid_playlist_pos
    remote_host
    escape
    get_valid_lists
    isa_valid_playlist
  );
}

use Carp 'croak';
use App::Pimpd;
use Term::ExtendedColor qw(fg);


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
        if(not invalid_regex($list)) {
          if($valid =~ /$list/im) {
            push(@choices, $valid);
          }
        }
        else {
          if($valid =~ /\Q$list/im) {
            push(@choices, $valid);
          }
        }
      }
      if(scalar(@choices) == 0) {
        print STDERR "No such playlist '" . fg($c[5], $list), "'\n";
        return;
      }


      print "'all' uses all playlists\n\n";

      my $i = 0;
      for my $choice(@choices) {
        print fg('bold', sprintf("%3d", $i)), " $choice\n";
        $i++;
      }
      print "choice: ";
      chomp(my $answer = <STDIN>);

      if( ($answer eq 'all') or ($answer eq '') ) {
        return @choices;
      }
      elsif($answer eq 'current') {
        return(undef);
      }

      if($answer ~~ @valid_lists) {
        $list = $answer;
      }
      # Make sure the number selected is in fact valid
      elsif($answer >= 0 and $answer < scalar(@valid_lists)) {
        $list = $choices[$answer];
      }
      else {
        croak("Playlist '$answer' is not valid\n");
      }
    }
  }
  return(@lists);
}

sub isa_valid_playlist {
  my @playlists = @_;
  my @lists = $mpd->collection->all_playlists;
  map { s/^\s+//m } @lists;
  return ($_[0] ~~ @lists) ? 1 : 0;
}

sub escape {
  my $str = shift;
  $str =~ s/([;<>\*\|`&\$!#\(\)\[\]\{\}:'"])/\\$1/gm;

  return $str;
}

sub remote_host {
  not exists($config{mpd_host}) and $config{mpd_host} = 'localhost';
  if(($config{mpd_host} eq 'localhost') or ($config{mpd_host} eq '127.0.0.1')) {
    return 0;
  }
  return 1;
}

sub invalid_regex {
  my $re = shift;
  eval { qr/$re/m };
  if($@) {
    return 1;
  }
  else {
    return 0;
  }
}


sub to_terminal {
  return (-t STDOUT) ? 1 : 0;
}


sub empty_playlist {
  if(scalar($mpd->playlist->as_items) == 0) {
    return 1;
  }
  return 0;
}

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

__END__

=pod

=head1 NAME

App::Pimpd::Validate - Package exporting various functions for validating data

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Validate;

    if(to_terminal()) {
      print "Yes, you can see me!\n";
    }

    $str = escape($str);

    if(invalid_playlist_pos(42)) {
      print STDERR "No song on playlist position 42!\n";
    }

=head1 DESCRIPTION

App::Pimpd::Validate provides functions for verifying certain conditions that's
crucial for other functions.

=head1 EXPORTS

=over

=item remote_host()

Returns true if the MPD server is located on a remote host.

The MPD server is assumed to be remote if the B<mpd_host> configuration file
variable is:

  not defined
or
  equals 'localhost'
or
  equals '127.0.0.1'

=item invalid_regex()

Parameters: $regex

Returns true if the provided regex is invalid.

=item empty_playlist()

Returns true if the current playlist is empty.

=item to_terminal()

Returns true if output is going to a TTY.

=item invalid_playlist_pos()

Parameters: $integer

Returns true if supplied argument is an invalid playlist position.

=item escape()

Parameters: $string
Returns:    $string

Takes the supplied string and escapes it from evil chars the shell might
otherwise munch.

=item get_valid_lists()

Parameters: @playlists
Returns:    @valid_playlists

Takes a list and traverses it, checking if every playlist exists.

If a playlist is found to be non-existant, tries to match the string against
all known playlists. If a partial match is found, prompts for validation.

=item isa_valid_playlist

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
