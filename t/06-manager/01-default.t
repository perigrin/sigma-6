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

    sub commit_description  {''}
    sub commit_id           {1}
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

    my $build;
    sub push_build { ::ok $build = $_[1], 'got a build' }
    sub fetch_build { ::ok('fetch_build'); $build }
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

ok my $build_id
    = $manager->start_build(
    { 'Git.target' => 'git@github.com:perigrin/Exportare.git' } ),
    'added a simple build';

ok $manager->get_build($build_id), 'build data is stored properly';
ok my @builds = $manager->check_all_builds(), 'check all builds works';
is @builds, 1, 'got the right number of builds';

is_deeply $c->first_from_plugin_with(
    '-CheckBuild' => sub { $_[0]->check_build($build_id) } ),
    $builds[0], 'CheckBuild looks right';

done_testing();
