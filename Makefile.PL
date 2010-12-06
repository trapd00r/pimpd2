use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'App::Pimpd',
    AUTHOR              => q{Magnus Woldrich <trapd00r@trapd00r.se>},
    # VERSION_FROM        => 'pimpd',
    #ABSTRACT_FROM       => 'pimpd',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    EXE_FILES =>           ['pimpd2'],
    PREREQ_PM => {
        'Test::More' => 0,
        'Audio::MPD' => 0,
        'Term::ExtendedColor' => 0.16,
    },
    #MAN1PODS            => {
    #    'pimpd' => 'blib/man1/pimpd.1',
    #  },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'pimpd-*' },
);
