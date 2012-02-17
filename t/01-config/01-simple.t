#!/usr/bin/env perl
use strict;

use Test::More;
use Test::Deep;

use Sigma6::Config::Simple;

my %config = (
    'Build::Manager' => {},
    'JSON' => {},
    'Git'  => { note_command => 'notes --ref=sigma6-test add -fm', },
    'Dzil' => {
        deps_command  => 'cpanm -L perl5 --installdeps Makefile.PL',
        build_command => 'prove -I perl5/lib/perl5 -lwrv t/'
    },
);

ok my $c = Sigma6::Config::Simple->new( config => \%config ),
    '->new(config => \%config) works';

is_deeply(
    Sigma6::Config::Simple->new(%config) => $c,
    '->new(%config) works'
);

can_ok( $c, 'first_from_plugin_with' );

$c->first_from_plugin_with(
    '-CheckBuild' => sub {

        ::ok $_[0]->does('Sigma6::Plugin::API::CheckBuild'),
            'first_from_plugin_with plugin does expected role';
    }
);

can_ok( $c, 'plugins_with' );
my @plugins = $c->plugins_with('-RenderJSON');
is( @plugins, 1, 'Got the expected number of plugins' );

done_testing();
