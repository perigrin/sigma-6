#!/usr/bin/env perl
use strict;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

use Sigma6::Server;

my $app = sub { Sigma6::Server->run_psgi(@_) };

test_psgi $app, sub {
    my $cb  = shift;
    my $res = $cb->( GET '/' );
    is( $res->code, 200, 'got an ok response' );
    my $content = $res->content;
    like( $content, qr/build/, 'contains the word build' );
};

done_testing;
