#!/usr/bin/env perl
package Sigma6::Smoker::script;
use strict;

use Getopt::Long 2.33 qw(:config gnu_getopt);
use Pod::Usage;
use Config::Tiny;

my $conf = {};

GetOptions(
    'config=s' => \$conf->{file},
    'target=s' => \$conf->{target},
    'dir=s'    => \$conf->{dir},
    'cmd=s'    => \$conf->{command},
    man        => sub { pod2usage( -verbose => 2 ) },
);

for ( keys %$conf ) {
    delete $conf->{$_} unless $conf->{$_};    # clear out the fake false values
}

if ( $conf->{file} ) {
    $conf = { %{ Config::Tiny->new->read( $conf->{file} )->{build} }, %$conf };
}

use Data::Dumper;
die Dumper $conf;

__END__

=head1 Sigma6 Smoker

Sigma6 ... like CIJoe but with 100% more Awesome

=head1 SYNOPSIS

    build --target git@github.com:perigrin/sigma-6.git --dir /tmp/foo --cmd 'dzil smoke'

=head1 DESCRIPTION

Sigma6 Smoker script will pull down a remote repository and automatically smoke it using the supplied command.

=head1 LICENSE

Sigma6 is available under the same terms as Perl itself.
