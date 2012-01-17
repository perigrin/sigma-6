#!/usr/bin/env perl
use strict;

use Test::More;

{

    package Sigma6::Config::Simple;
    use Moose;

    with qw(Sigma6::Config);

    my %config = (
        'Build::Manager' => {},
        'Template::Tiny' => {},
        'Smoker::Simple' => {
            workspace      => '/tmp/sigma6/test',
            smoker_command => 'bin/smoker.pl --config etc/sigma6.ini',
        },
        'Git'  => { note_command => 'notes --ref=sigma6-test add -fm', },
        'Dzil' => {
            deps_command  => 'cpanm -L perl5 --installdeps Makefile.PL',
            build_command => 'prove -I perl5/lib/perl5 -lwrv t/'
        },
    );

    sub BUILD {
        shift->add_plugins( keys %config );
    }

    sub get_section_config {
        my $self    = shift;
        my $section = shift;
        return $config{$section};
    }
}

ok( my $c = Sigma6::Config::Simple->new(), 'got new Sigma6::Config::Simple' );
can_ok( $c, 'first_from_plugin_with' );

$c->first_from_plugin_with(
    '-CheckBuild' => sub {
        
        ::ok $_[0]->does('Sigma6::Plugin::API::CheckBuild'),
            'first_from_plugin_with plugin does expected role';
    }
);

can_ok($c, 'plugins_with');
my @plugins = $c->plugins_with('-RenderHTML');
is(@plugins, 1, 'Got the expected number of plugins');


done_testing();
