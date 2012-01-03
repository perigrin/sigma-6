#!/usr/bin/env perl
use strict;
use Plack::Test;

use Test::More;
use Test::HTML::Differences;

use HTTP::Request::Common;
use Sigma6;
use Sigma6::Config::GitLike;

my $c = Sigma6::Config::GitLike->new();

$c->load('t/etc/');

my $app = sub { Sigma6->new( config => $c )->run_psgi(@_) };

my %page = (
    '/' => q{
    <!DOCTYPE html>
    <html>
        <head>
            <title>Sigma6</title>
        </head>
        <body>
            <h1></h1>
            <p>Nothing Built Yet</p>
        </body>
    </html>
}
);

test_psgi $app => sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    is $res->code, 200, 'got a 200 for /';
    eq_or_diff_html( $res->content, $page{'/'}, 'HTML looks okay' );

    $res = $cb->( POST '/', [ 
        'Git.target' => 'git@github.com:perigrin/Exportare.git',
    ] );
    ok $res->is_redirect, 'got back a redirect';
    diag $res->dump;
};

done_testing;
