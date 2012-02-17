#!/usr/bin/env perl
use strict;
use Plack::Test;

use Test::More;
use Test::TempDir qw(tempfile tempdir);

use HTTP::Request::Common qw(GET POST DELETE);
use Sigma6::Config::Simple;
use Sigma6;

use JSON::Any;

{

    package Sigma6::Plugin::TestSmoker;
    use Moose;
    extends qw(Sigma6::Plugin::Smoker::Simple);

    use Sigma6::Smoker;

    sub run_smoke { ::pass 'run smoke' }

    sub start_smoker {
        ::pass 'start_smoker';
        my $smoker = Sigma6::Smoker->new( config => shift->config );
        $smoker->setup_workspace;
        $smoker->setup_smoker;
        $smoker->run_smoker;
        $smoker->teardown_smoker;
        $smoker->teardown_workspace;
    }
}

{

    package Sigma6::Plugin::Test::Queue;
    use Moose;
    extends qw(Sigma6::Plugin);
    with qw(Sigma6::Plugin::API::Queue);

    my @builds;
    sub push_build { ::ok push( @builds, $_[1] ), 'got a build' }
    sub fetch_build { ::pass('fetch_build'); shift @builds }
}

my ( $fh, $file ) = tempfile();

my %config = (
    'Build::Manager' => {},
    'Logger'         => { config => 'logger.conf' },
    'JSON'           => {},
    'Test::Queue'    => {},
    'TestSmoker'     => {
        workspace      => tempdir(),
        smoker_command => 'bin/smoker.pl --config etc/sigma6.ini',
    },
    'Git'  => { note_command => 'notes --ref=sigma6-test add -fm', },
    'Dzil' => {
        deps_command  => 'cpanm -L perl5 --installdeps Makefile.PL',
        build_command => 'prove -I perl5/lib/perl5 -lwrv t/'
    },
);

my $c = Sigma6::Config::Simple->new( config => \%config );
my $app = Sigma6->new( config => $c )->as_psgi;

test_psgi $app => sub {
    my $cb = shift;
    my $res = $cb->( GET "/", 'Accept' => 'text/html' );
    is $res->code, 200, 'got a 200 for /';

    {
        $res = $cb->(
            POST '/builds',
            [ 'target' => 'git@github.com:perigrin/Exportare.git', ]
        );
        is $res->code, 202, 'got a 202';

        ok my $location = $res->header('Location'), 'got location header';
        $res = $cb->( GET $location );
        is $res->code, 200, "got 200 for $location";
    }
    {
        my $res = $cb->( GET "/builds", );
        is $res->code, 200, 'got 200 for /';
        my @builds
            = JSON::Any->new( allow_blessed => 1 )->decode( $res->content );
        is @builds, 1, 'got the expected number of builds';

    }

    {
        my $res = $cb->(
            POST '/builds',
            [ 'target' => 'git@github.com:perigrin/json-any.git', ]
        );
        is $res->code, 202, 'got a 202';

        ok my $location = $res->header('Location'), 'got location header';
        $res = $cb->( GET $location );
        is $res->code, 200, "got 200 for $location";

    }

    {
        my $res = $cb->( GET "/builds", );
        is $res->code, 200, 'got 200 for /';
        my $builds
            = JSON::Any->new( allow_blessed => 1 )->decode( $res->content );
        is @$builds, 2, 'got the expected number of builds';
    }
    {
        my $res = $cb->(
            POST '/builds',
            [ 'target' => 'git@github.com:perigrin/json-any.git', ]
        );
        is $res->code, 202, 'got a 202';

        ok my $location = $res->header('Location'), 'got location header';
        $res = $cb->( GET $location );
        is $res->code, 200, "got 200 for $location";
        $res = $cb->( DELETE $location);
        is $res->code, 200, "got 200 for DELETE $location";
        $res = $cb->(GET $location);
        is $res->code, 404, "got 404 for $location";
    }
};

done_testing;
