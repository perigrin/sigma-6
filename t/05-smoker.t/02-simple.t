#!/usr/bin/env perl -w
use strict;
use Test::More;
use Test::TempDir qw(tempfile tempdir);
use Test::Deep;
use Test::Fatal;
use Sigma6::Config::Simple;

my $build = { 'Git.target' => 'git@github.com:perigrin/Exportare.git' };

ok my $c = Sigma6::Config::Simple->new(
    'Smoker::Simple' => {
    	workspace      => tempdir(),
   	smoker_command => 'bin/smoker.pl --config etc/sigma6.ini',
    }
), 'got a new config';

ok( (my $smoker) = $c->plugins_with('-Smoker'),  'got the smoker plugin');

isa_ok $smoker, 'Sigma6::Plugin::Smoker::Simple'; 

is exception { $smoker->setup_smoker( $build ) }, undef, 'setup smoker lived okay';

done_testing;
