#!/usr/bin/env perl -w
use strict;
use Test::More;
use Test::Deep;
use Test::TempDir qw(tempfile);
use Sigma6::Config::Simple;
use Sigma6::Model::Build;
my ( $fh, $file ) = tempfile();
ok my $c = Sigma6::Config::Simple->new(
    'Queue::Mmap' => {
        file        => $file,
        size        => 10,
        record_size => 20,
        mode        => 0666,
    },
) => 'got new config';

ok my @plugins = $c->plugins_with('-Queue'), 'plugins_with Queue';
is @plugins, 1, 'only one plugin';

my $q = shift @plugins;
isa_ok $q, 'Sigma6::Plugin::Queue::Mmap';
ok $q->does('Sigma6::Plugin::API::Queue'), 'does Sigma6::Plugin::API::Queue';

my $build = Sigma6::Model::Build->new({ 'Git.target' => 'git@github.com:perigrin/Exportare.git' });

ok $q->push_build($build), 'pushed a build';
is_deeply( $q->fetch_build, $build, 'got back the build' );

ok $c->first_from_plugin_with(
    '-EnqueueBuild' => sub { shift->push_build($build) } ), 'pushed a build';

$c->first_from_plugin_with(
    '-DequeueBuild' => sub {
        ::is_deeply( shift->fetch_build, $build, 'build data looks okay' );
    }
);

done_testing;
