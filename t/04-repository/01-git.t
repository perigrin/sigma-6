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

my $build = { 'Git.target' => 'git@github.com:perigrin/Exportare.git', };

$c->first_from_plugin_with(
    '-SetupRepository' => sub { shift->setup_repository($build) } );

ok -d $workspace, 'workspace exists';
my $dir = $workspace. '/'. $repo[0]->humanish($build->{'Git.target'});
ok -d $dir, 'workdir exists too';
my $sha1 = substr(
    (   Git::Wrapper->new($dir)
            ->_cmd( 'ls-remote', $build->{'Git.target'}, 'HEAD' )
    )[0],
    0, 7
);

is $c->first_from_plugin_with(
    '-Repository' => sub { $_[0]->commit_id($build); }
    ),
    $sha1, 'got a commit_id';

my ($desc) = Git::Wrapper->new($dir)->_cmd( 'log', '--oneline', '-1' );

is $c->first_from_plugin_with(
    '-Repository' => sub { $_[0]->commit_description($build) } ), $desc,
    'got a commit_description';

done_testing();

