#!/usr/bin/env perl
use Sigma6;
use Config::Tiny;

my $c = Config::Tiny->new->read('sigma6.ini');
my $app = sub { Sigma6->new($c)->run_psgi(@_) };

__END__
