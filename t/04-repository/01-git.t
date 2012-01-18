#!/usr/bin/perl -w

use strict;
use Test::More;
use Test::TempDir qw(tempdir);
use Sigma6::Config::Simple;

my $workspace = tempdir();

{

    package Sigma6::Plugin::Test::Workspace;
    use Moose;
    with qw(Sigma6::Plugin::API::Workspace);

    sub setup_workspace    { ::ok -e $workspace, "setup $workspace" }
    sub teardown_workspace { ::ok -e $workspace, "teardown $workspace"; }
    sub workspace          {$workspace}

}

my $c = Sigma6::Config::Simple->new(
    'Git'             => {},
    'Test::Workspace' => {}
);

ok my @repo = $c->plugins_with('-Repository'), 'got the repository';
is @repo, 1, 'only one repo configured';
isa_ok $repo[0], 'Sigma6::Plugin::Git';

my $build_data = { 'Git.target' => 'git@github.com:perigrin/Exportare.git', };

$c->first_from_plugin_with(
    '-SetupRepository' => sub { shift->setup_repository($build_data) } );

is $repo[0]->target, $build_data->{'Git.target'}, 'right target';
is $c->first_from_plugin_with( '-Repository' => sub { shift->target } ),
    $build_data->{'Git.target'}, '... even when we check the long way';

ok -d $workspace, 'workspace exists';

my $sha1 = substr(
    (   Git::Wrapper->new($workspace)
            ->_cmd( 'ls-remote', $build_data->{'Git.target'}, 'HEAD' )
    )[0],
    0, 7
);

is $c->first_from_plugin_with(
    '-Repository' => sub { $_[0]->commit_id($build_data); }
    ),
    $sha1, 'got a commit_id';

my ($desc) = Git::Wrapper->new($workspace)->_cmd( 'log', '--oneline', '-1' );

is $c->first_from_plugin_with(
    '-Repository' => sub { $_[0]->commit_description($build_data) } ), $desc,
    'got a commit_description';

done_testing();

