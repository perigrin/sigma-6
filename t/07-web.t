#!/usr/bin/env perl
use strict;
use Plack::Test;

use Test::More;
use Test::HTML::Differences;
use Test::TempDir qw(tempfile tempdir);

use HTTP::Request::Common;
use Sigma6::Config::Simple;
use Sigma6;

{

    package Sigma6::Plugin::TestSmoker;
    use Moose;
    extends qw(Sigma6::Plugin);
    with qw(
        Sigma6::Plugin::API::Smoker
        Sigma6::Plugin::API::Workspace
    );

    sub check_smoker    { ::pass 'check smoker' }
    sub run_smoke       { }
    sub setup_smoker    { }
    sub smoker_command  { }
    sub start_smoker    { ::pass 'started smoker' }
    sub teardown_smoker { ::pass 'teardown smoker' }

    sub setup_workspace    { }
    sub teardown_workspace { }
    sub workspace          { ::tempdir() }
}

my ( $fh, $file ) = tempfile();

my %config = (
    'Build::Manager' => {},
    'Template::Tiny' => {},
    'JSON'           => {},
    'Queue::Mmap'    => {
        file        => $file,
        size        => 10,
        record_size => 20,
        mode        => 0666,
    },
    'TestSmoker' => {},
    'Git'        => { note_command => 'notes --ref=sigma6-test add -fm', },
    'Dzil'       => {
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
        my $res = $cb->(
            POST '/',
            [ 'Git.target' => 'git@github.com:perigrin/json-any.git', ]
        );
        ok $res->is_redirect, 'got back a redirect';

        my $location = $res->header('Location');
        $res = $cb->( GET $location );
        is $res->code, 200, "got 200 for $location";
        diag $res->dump;
    }
};

done_testing;
