#!/usr/bin/env perl
use strict;
use Test::More;
use Test::Deep;
use Test::TempDir qw(tempfile);
use Sigma6::Config::Simple;
use Sigma6::Model::Build;

{

    package Sigma6::Plugin::Test::Smoker;
    use Moose;
    extends qw(Sigma6::Plugin);
    with qw(Sigma6::Plugin::API::Smoker);

    sub setup_smoker    { }
    sub run_smoke       { }
    sub smoker_command  { }
    sub check_smoker    {"Running"}
    sub start_smoker    { ::pass('Started Smoker') }
    sub teardown_smoker { }

}

{

    package Sigma6::Plugin::Test::Repository;
    use Moose;
    extends qw(Sigma6::Plugin);
    with qw(
        Sigma6::Plugin::API::BuildData
        Sigma6::Plugin::API::Repository
    );
    my $id = 1;
    sub revision { $id++ }
    sub build_data { Sigma6::Model::Build->new( @_, type => 'mock' ) }
    sub revision_description {''}
    sub revision_status      {''}
    sub repository_directory {''}
    sub repository           {''}
    sub setup_repository     {''}
    sub teardown_repository  {''}
    sub target               { }

}

{

    package Sigma6::Plugin::Test::Queue;
    use Moose;
    extends qw(Sigma6::Plugin);
    with qw(Sigma6::Plugin::API::Queue);

    my @builds;
    sub push_build { ::ok push( @builds, $_[1] ), 'got a build' }
    sub fetch_build { ::ok('fetch_build'); shift @builds }
}

my ( $fh, $file ) = tempfile();

my $c = Sigma6::Config::Simple->new(
    'BuildManager::Kioku' => { dsn => 'dbi:SQLite::memory:' },
    'Test::Repository'    => {},
    'Test::Smoker'        => {},
    'Test::Queue'         => {},
);

ok my ($manager) = $c->plugins_with('-BuildManager'), 'got Manager';

isa_ok( $manager, 'Sigma6::Plugin::BuildManager::Kioku' );

is( $_, $manager, "CheckBuild is the same" )
    for $c->plugins_with('-CheckBuild');

is( $_, $manager, "StartBuild is the same" )
    for $c->plugins_with('-StartBuild');

can_ok $manager, qw(start_build check_build check_all_builds);

{
    ok my $build = $manager->start_build(
        Sigma6::Model::Build->new(
            {   'target' => 'git@github.com:perigrin/Exportare.git',
                type     => 'mock'
            }
        )
        ),
        'added a simple build';
    is_deeply $manager->get_build( $build->{id} ),
        $build, 'build data is stored properly';

    is_deeply $c->first_from_plugin_with(
        '-CheckBuild' => sub { $_[0]->check_build($build) }
        ),
        $build, 'CheckBuild looks right';
}
{
    ok my @builds = $manager->check_all_builds(), 'check all builds works';
    is @builds, 1, 'got the right number of builds';
}
{
    $manager->start_build(
        Sigma6::Model::Build->new( { 'target' => 'Moose', type => 'mock' } )
    );
    ok my @builds = $manager->check_all_builds(), 'check all builds works';
    is @builds, 2, 'got the right number of builds';
}

done_testing();

