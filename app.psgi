#!/usr/bin/env perl
use strict;
use warnings;

use lib qw(lib);
use Sigma6;
use Sigma6::Config::GitLike;

my $c = Sigma6::Config::GitLike->new();
$c->load( $ENV{PWD} );
my $app = Sigma6::Web->new( config => $c )->as_psgi;

__END__
