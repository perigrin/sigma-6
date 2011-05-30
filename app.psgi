#!/usr/bin/env perl
use Sigma6;
use Config::Tiny;

my $c = Config::Tiny->new->read('sigma6.ini');

my $app = Sigma6->new($c);

my $handler = sub { $app->run_psgi(@_) };

__END__
