#!/usr/bin/env perl
use strict;
use Plack::Test;

use Test::More;
use Test::HTML::Differences;
use Test::TempDir qw(tempfile tempdir);

use HTTP::Request::Common;
use Sigma6::Config::Simple;
use Sigma6;

use JSON::Any;


use DDP;

{

    package Sigma6::Plugin::TestSmoker;
    use Moose;
    extends qw(Sigma6::Plugin::Smoker::Simple);

    use Sigma6::Smoker;
    use DDP;

    sub run_smoke { ::pass 'run smoke' }

    sub start_smoker {
        ::pass 'start_smoker';
        my $smoker = Sigma6::Smoker->new( config => shift->config );
        $smoker->setup_workspace;
        #        $smoker->setup_repository;
        $smoker->setup_smoker;
        $smoker->run_smoker;
        #        $smoker->record_results;
        $smoker->teardown_smoker;
        #       $smoker->teardown_repository;
        $smoker->teardown_workspace;
        #       $self->clear_build_data;

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
    'Template::Tiny' => {},
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

my $app = sub { Sigma6->new( config => $c )->run_psgi(@_) };

my %page = (
    '/' => q{
        <html>                                                              
          <head>                                                            
            <title>Sigma6</title>                                           
          </head>                                                           
          <body>                                                            
            <h1>Sigma6 Builds</h1>                                          
            <p>No Builds Yet</p>                                            
            <form action="/" method="POST">                                 
              <select id="some_name" name="some_name" onchange="" size="1"> 
                <option value="Git">Git</option>                            
              </select>                                                     
              <input type="text" value="target"></input>                    
              <input type="submit"></input>                                 
            </form>                                                         
          </body>                                                           
        </html>
}
);

test_psgi $app => sub {
    my $cb = shift;
    my $res = $cb->( GET "/", 'Accept' => 'text/html' );
    is $res->code, 200, 'got a 200 for /';
    eq_or_diff_html( $res->content, $page{'/'}, 'HTML looks okay' );

    {
        $res = $cb->(
            POST '/',
            [ 'Git.target' => 'git@github.com:perigrin/Exportare.git', ]
        );
        ok $res->is_redirect, 'got back a redirect';

        my $location = $res->header('Location');
        $res = $cb->( GET $location );
        is $res->code, 200, "got 200 for $location";
    }
    {
        my $res = $cb->( GET "/", );
        is $res->code, 200, 'got 200 for /';
        my @builds
            = JSON::Any->new( allow_blessed => 1 )->decode( $res->content );
        is @builds, 1, 'got the expected number of builds';

    }

    {
        my $res = $cb->(
            POST '/',
            [ 'Git.target' => 'git@github.com:perigrin/json-any.git', ]
        );
        ok $res->is_redirect, 'got back a redirect';

        my $location = $res->header('Location');
        $res = $cb->( GET $location );
        is $res->code, 200, "got 200 for $location";
    }

    {
        my $res = $cb->( GET "/", );
        is $res->code, 200, 'got 200 for /';
        my $builds
            = JSON::Any->new( allow_blessed => 1 )->decode( $res->content );
        is @$builds, 2, 'got the expected number of builds';
    }
};

done_testing;
