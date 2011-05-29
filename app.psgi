#!/usr/bin/env perl
use Sigma6;
my $app = Sigma6->new(
    target => 'https://perigrin@github.com/perigrin/sigma-6.git',
);
my $handler = sub { $app->run_psgi(@_) };

__END__
