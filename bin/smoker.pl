#!/usr/bin/env perl
use strict;
use warnings;
use lib qw(lib);

use Sigma6::Smoker;
use Sigma6::Config::GitLike;
use Getopt::Long;

my $config = $ENV{PWD};

GetOptions( "config=s" => \$config );

my $c = Sigma6::Config::GitLike->new();
$c->load($config);

Sigma6::Smoker->new( config => $c )->run();

__END__

=head1 NAME smoke.pl

Sigma6 ... like CIJoe but with 100% more Awesome

=head1 SYNOPSIS

    bin/smoker.pl --config sigma6.ini

=head1 DESCRIPTION

Sigma6 Smoker script will pull down a remote repository and automatically smoke it using the supplied command.

=head1 LICENSE

Sigma6 is available under the same terms as Perl itself.
