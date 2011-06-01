#!/usr/bin/env perl
use Sigma6;
use Config::Tiny;

my $c = Config::Tiny->new->read('sigma6.ini');

my $handler = Sigma6->new($c)->to_app; 

__END__
