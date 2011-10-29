#!/usr/bin/env perl
use strict;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Sigma6;
use Sigma6::Config::GitLike;
use Data::Dumper;

my $c = Sigma6::Config::GitLike->new();

$c->load('t/etc/');

my $app = sub { Sigma6->new( config => $c )->run_psgi(@_) };

test_psgi $app, sub {
    my $cb = shift;
    {
        my $res = $cb->( GET "/" );
        is $res->code, 200, 'got a 200 for /';
        my $content = $res->content;

        like $content,
            qr|<title>Sigma6: git\@github.com:perigrin/Exportare.git</title>|,
            'title looks good';
        like $content, qr|\Q<h1>Build [unknown]</h1>\E|, 'h1 looks good';
        like $content,
            qr|\Q<div><pre><code>Repository work tree missing. Kick off a build.</code></pre></div>\E|,
            'content looks good';
    }

    {
        my $res = $cb->( POST '/' );
        ok $res->is_redirect, 'got back a redirect';
    }
};

done_testing;