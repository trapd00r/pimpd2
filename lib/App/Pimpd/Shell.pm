package App::Pimpd::Shell;
use strict;

BEGIN {
  use Exporter;
  use vars qw(@ISA @EXPORT);
  @ISA = qw(Exporter);
  @EXPORT = qw(
    spawn_shell
  );
}

use App::Pimpd;
use App::Pimpd::Doc;
use App::Pimpd::Info;
use App::Pimpd::Player;
use App::Pimpd::Commands;
use App::Pimpd::Transfer;
use App::Pimpd::Collection::Album;
use App::Pimpd::Collection::Search;
use App::Pimpd::Playlist;
use App::Pimpd::Playlist::Favorite;
use App::Pimpd::Playlist::Randomize;
use App::Pimpd::Playlist::Search;
use App::Pimpd::Validate;
use Term::ExtendedColor qw(fg);
use Term::ReadLine; # Term::ReadLine::Gnu prefered

my $opts;
sub spawn_shell {
  my $option = shift;
  my($cmd, $arg, @cmd_args); # for later use


  #print help('shell');


  $opts = {

    'randomize'      => sub {
      if(!defined($_[0])) {
        $_[0] = 100;
      }
      elsif(defined($_[0]) and $_[0] !~ /^\d+$/m) {
        print STDERR "Need a valid integer\n";
        $_[0] = 100;
      }
      print 'Adding ' . fg('bold', @_) . " random tracks...\n";
      my @random = randomize(@_);

      print "$_\n" for @random;
      clear_playlist();
      add_to_playlist(@random);
    },


    'randomalbum'   => sub {
      $_[0] = 10 if(!$_[0]);
      print 'Adding ' . fg('bold', $_[0]) . " random albums...\n\n";
      my @albums = randomize_albums($_[0]);

      my $old = undef;
      for(@albums) {
        my($album_dir) = $_ =~ m|(.+)/.+|m;
        if($old ne $album_dir) {
          print "> $album_dir\n";
          $old = $album_dir;
        }
      }
      print "\n";
      clear_playlist();
      add_to_playlist(@albums);
    },


    'playlist'       => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty\n";
        return 1;
      }
      show_playlist();
      print fg('bold', ' >'), '> ', current(), "\n";
    },


    'love'           => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      add_to_favlist(@_);
    },

    'loved?'          => sub {
      if(already_loved($mpd->current->file)) {
        printf("%s, %s by %s is loved.\n",
          fg('bold', 'Yes'),
          fg($c[10], $mpd->current->title),
          fg($c[2],  fg('bold', $mpd->current->artist)),
        );
      }
      else {
        printf("%s, %s by %s is not loved yet.\n",
          fg('bold', 'No'),
          fg($c[10], $mpd->current->title),
          fg($c[2],  fg('bold', $mpd->current->artist)),
        );
      }
    },

    'unlove'            => sub {
      if(!@_) {
        print help('unlove');
        return;
      }
      remove_favorite(@_);
    },

    'track'           => sub {
      $_[0] = 1 if $_[0] !~ /^\d+$/m;
      play_pos_from_playlist(@_);
    },

    'copy'            => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      cp($config{target_directory});
    },

    'copya'      => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      cp_album($config{target_directory});
    },

    # FIXME
    'copy-list'       => sub { cp_list(@_); },

    'info'               => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      info();
    },

    'monitor'         => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty - there's nothing to monitor\n";
        return 1;
      }
      #monitor();
      #FIXME
    },

    'sartist'         => sub {
      my $artist = join(' ', @_);
      if(!$artist) {
        print help('sartist');
        return;
      }
      add_to_playlist(search_db_artist($artist));
    },

    'salbum'          => sub {
      my $album = join(' ', @_);
      if(!$album) {
        print help('salbum');
        return;
      }
      add_to_playlist(search_db_album($album));
    },

    'stitle'          => sub {
      my $title = join(' ', @_);
      if(!$title) {
        print help('stitle');
        return;
      }

      my @result = search_db_title($title);
      if(@result) {
        print "$_\n" for @result;
        add_to_playlist(@result);
      }
      else {
        printf("No titles matching '%s'\n",
          fg($c[5], $title),
        );
      }
    },

    'sany'            => sub {
      my $search = join(' ', @_);
      if(!$search) {
        print help('sany');
        return;
      }
      add_to_playlist(search_db_quick($search));
    },

    'splaylist'       => sub {
      my $search = join(' ', @_);
      if(!$search) {
        print help('splaylist');
        return;
      }
      print "$_\n" for values %{ search_playlist($search) };
      my $result = search_playlist($search);
      if(scalar(keys(%{ $result })) > 0) {
        print "$_\n" for values %{ $result };
        queue( keys % { search_playlist($search) } );
      }
      else {
        print "No match\n";
      }
    },

    'slove'           => sub {
      my $search = join(' ', @_);
      my @files = search_favlist($search);
      print "$_\n" for @files;
      add_to_playlist(@files);
    },


    'sap'             => sub {
      my $search = join(' ', @_);
      if(!$search) {
        print help('slove');
        return;
      }
      my @result = search_all_playlists($search);
      print "$_\n" for @result;
      add_to_playlist(@result);
    },


    'albums'          => sub {
      if(empty_playlist() and !@_) {
        print STDERR "Nothing is playing, and no argument supplied\n";
        return 1;
      }
      my $artist = join(' ', @_);
      print "$_\n" for albums_by_artist($artist);
    },

    'songs'           => sub { print $_->file, "\n" for songs_on_album(@_); },
    'add-album'       => sub {
      add_to_playlist( map{ $_->file } get_album_songs(@_));
    },
    'playlists'       => sub { print "$_\n" for list_all_playlists(); },
    'add'             => sub {

      if($_[0] eq 'songs') {
        local $\ = "\n";
        my @songs = map { $_->file } songs_on_album();
        printf("Adding %d songs from %s\n",
          scalar(@songs), fg('bold', $mpd->current->album),
        );
        add_to_playlist(@songs);
      }

      elsif($_[0] eq 'slove') {
        shift @_; # so we can grab the PATTERN
        my @result = search_favlist(@_);

        if(scalar(@result) > 0) {
          print "$_\n" for @result;

          add_to_playlist(@result);
          printf("\nAdded %s loved %s matching '%s'\n",
            fg('bold', scalar(@result)),
            (scalar(@result) > 1) ? 'songs' : 'song',
            fg($c[4], fg('bold', $_[0])),
          );
        }
        else {
          printf("No songs matching '%s' were found\n",
            fg($c[4], fg('bold', $_[0])),
          );
        }
      }

      else {
        add_playlist(@_);
      }
    },

    'next'            => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty!\n";
        return 1;
      }
      next_track();
      print current() . "\n";
    },

    'previous'        => sub {
      if(empty_playlist()) {
        print STDERR "Playlist is empty!\n";
        return 1;
      }
      previous_track();
      print current() . "\n";
    },

    'pause'           => sub {
      toggle_pause();
      print $mpd->status->state . "\n";
    },

    'shuffle'         => sub {
      $mpd->playlist->shuffle;
      print "New playlist version is " .$mpd->status->playlist . "\n"
    },

    'np'              => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      print current() . "\n";
    },

    'nprt'            => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      np_realtime();
    },

    'queue'            => sub {
      if(invalid_playlist_pos(@_)) {
        printf("No such song%s\n", (@_ < 1) ? 's' : '');
        return 1;
      }
      queue(@_);
    },

    'random'           => sub {
      $mpd->random;
      my $status =  ($mpd->status->random)
        ? "Random: " . fg('bold', 'On')
        : "Random: " . fg('bold', 'Off');
      print "$status\n";
    },

    'repeat'           => sub {
      $mpd->repeat;
      my $status = ($mpd->status->repeat)
        ? "Repeat: " . fg('bold', 'On')
        : "Repeat: " . fg('bold', 'Off');
      print "$status\n";
    },

    'randomtrack'      => sub {
      play_pos_from_playlist(random_track_in_playlist());
      print current(), "\n";
    },

    'external'         => sub { songs_in_playlist(@_); },
    'clear'            => sub { clear_playlist() },
    'crop'             => sub { $mpd->playlist->crop; },
    'stop'             => sub { stop(); },
    'kill'             => sub { player_destruct(); },
    'play'             => sub {
      if(empty_playlist()) {
        print STDERR "Nothing is playing - playlist is empty\n";
        return 1;
      }
      play();
    },

    'delete-album'     => \&delete_album,

    'rmalbum'          => sub { remove_album_from_playlist(@_); },
    'exit'             => sub { exit(0); },
    ':q'               => sub { exit(0); },
    'help'             => sub {
      if( defined($opts->{$_[0]}) ) {
        print help($_[0]);
      }
      else {
        print help('shell');
      }
    },
  };

  while(1) {
    #print fg($c[6], 'pimpd'), fg('bold', '> ');

    #chomp(my $choice = <STDIN>);
    my @available_cmd = keys(%{$opts});
    push(@available_cmd, 'shell');

    my $term = Term::ReadLine->new('pimpd2');
    my $attr = $term->Attribs;

    $attr->{completion_function} = sub {
      my($text, $line, $start) = @_;
      return @available_cmd;
    };

    $attr->{autolist} = 0;
    $attr->{maxcomplete} = 0;
    # Sane keymap please.
    $term->set_keymap('vi');

    my $choice;

    while(1) {
      $choice = $term->readline(fg($c[6], 'pimpd') . fg('bold', '> '));
      $term->addhistory($choice) if $choice =~ /\S/m;

      ($cmd) = $choice =~ m/^(\S+)/m;
      ($arg) = $choice =~ m/\s+(.+)$/m;
      @cmd_args  = split(/\s+/m, $arg);

      if(defined($opts->{$cmd})) {
        $mpd->play;
        $opts->{$cmd}->(@cmd_args);
      }
      else {
        $opts->{help}->();
        print STDERR "No such option '", fg($c[5], $cmd), "'.\n";
      }
    }
  }
  exit(0);
}



1;

__END__

=pod

=head1 NAME

App::Pimpd::Shell - Pimpd interactive shell

=head1 SYNOPSIS

    use App::Pimpd;
    use App::Pimpd::Shell;

    spawn_shell();

=head1 DESCRIPTION

App::Pimpd::Shell contains the definitions set up for an interactive shell with
tabcompletion support that can handle most of this programs options.

=head1 EXPORTS

=over

=item spawn_shell()

Spawn the shell.

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
