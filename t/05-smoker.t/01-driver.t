#!/usr/bin/env perl -w
use strict;
use lib qw(t/lib);

use Test::More;
use Test::TempDir qw(tempfile tempdir);
use Test::Deep;
use Test::Fatal;

use Sigma6::Smoker;
use Sigma6::Config::Simple;

my $c = Sigma6::Config::Simple->new(
    'Test::Mockup' => {
        workspace => tempdir(),
        build     => { target => 'foo' },
        results   => ['pass'],
    },
);

ok( my $driver = Sigma6::Smoker->new( config => $c ), 'got new driver' );

ok !$driver->has_build_data, 'driver has no build data';

is_deeply $driver->build_data, { target => 'foo' }, 'build looks okay';

ok $driver->has_build_data, 'driver has build data';

is exception { $driver->run }, undef, 'driver->run lives';

ok !$driver->has_build_data, 'build_data is gone';

done_testing;
