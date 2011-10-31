#!/usr/bin/env perl
use strict;
use warnings;

use lib qw(lib);
use Sigma6;
use Sigma6::Config::GitLike;

my $c = Sigma6::Config::GitLike->new();
$c->load( $ENV{PWD} );
my $app = sub { Sigma6->new( config => $c )->run_psgi(@_) };

__END__
