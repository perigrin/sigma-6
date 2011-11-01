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
            qr|\Q<title>\ESigma6: git\@github.com:perigrin/Exportare.git\Q</title>\E|oi,
            'title looks good';
        like $content, qr|\Q<h1>\EBuild [0-9a-f]{7}\Q</h1>\E|oi, 'h1 looks good';
    }

    {
        my $res = $cb->( POST '/' );
        ok $res->is_redirect, 'got back a redirect';
    }
};

done_testing;
