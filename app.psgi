#!/usr/bin/env perl
use Sigma6;

my $app = Sigma6->new(
    target    => $ENV{SIGMA6_TARGET},
    build_cmd => $ENV{SIGMA6_BUILD},
);

my $handler = sub { $app->run_psgi(@_) };

__END__
