#!/usr/bin/env perl
use strict;
use Test::More;
use Test::Deep;
use Test::TempDir qw(tempfile);
use Sigma6::Config::Simple;

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
    with qw(Sigma6::Plugin::API::Repository);

    my $id = 1;
    sub commit_id { $id++ }

    sub commit_description  {''}
    sub commit_status       {''}
    sub repository          {''}
    sub setup_repository    {''}
    sub teardown_repository {''}
    sub target              { }

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
    'Build::Manager'   => {},
    'Test::Repository' => {},
    'Test::Smoker'     => {},
    'Test::Queue'      => {},
);

ok my ($manager) = $c->plugins_with('-BuildManager'), 'got Manager';

isa_ok( $manager, 'Sigma6::Plugin::Build::Manager' );

is( $_, $manager, "CheckBuild is the same" )
    for $c->plugins_with('-CheckBuild');

is( $_, $manager, "StartBuild is the same" )
    for $c->plugins_with('-StartBuild');

can_ok $manager, qw(start_build check_build check_all_builds);

{
    ok my $build
        = $manager->start_build(
        { 'Git.target' => 'git@github.com:perigrin/Exportare.git' } ),
        'added a simple build';
    is_deeply $manager->get_build( $build->{id} ),
        $build, 'build data is stored properly';

    is_deeply $c->first_from_plugin_with(
        '-CheckBuild' => sub { $_[0]->check_build( $build->{id} ) }
        ),
        $build, 'CheckBuild looks right';
}
{
    ok my @builds = $manager->check_all_builds(), 'check all builds works';
    is @builds, 1, 'got the right number of builds';
}
{
    $manager->start_build( { 'CPAN.target' => 'Moose' } );
    ok my @builds = $manager->check_all_builds(), 'check all builds works';
    is @builds, 2, 'got the right number of builds';
}

done_testing();

