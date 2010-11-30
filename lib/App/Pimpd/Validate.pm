#!/usr/bin/perl
package App::Pimpd::Validate;

require Exporter;
@ISA = 'Exporter';

our @EXPORT = qw(invalid_regex);

use strict;
use Carp;
use Data::Dumper;
$Data::Dumper::Terse     = 1;
$Data::Dumper::Indent    = 1;
$Data::Dumper::Useqq     = 1;
$Data::Dumper::Deparse   = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys  = 1;

use App::Pimpd;


=head3 invalid_regex()

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




1;
