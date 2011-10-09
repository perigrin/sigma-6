#!/usr/bin/env perl
use Sigma6;
use Sigma6::Config::GitLike;

my $c = Sigma6::Config::GitLike->new();
my $app = sub { Sigma6->new($c)->run_psgi(@_) };

__END__
