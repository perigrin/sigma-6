#!/usr/bin/env perl
use strict;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Config::Tiny;
use Sigma6;
use File::Temp qw(tempdir);
use Data::Dumper;

my $c = {
    'server' => {
        'smoker_config'  => 'sigma6.ini',
        'smoker_command' => 'bin/smoke.pl'
    },
    'build' => {
        'target'        => 'git@github.com:perigrin/sigma-6.git',
        'temp_dir'      => tempdir( CLEANUP => 1 ) . '/sigma6',
        'build_command' => 'dzil smoke --automated',
        'deps_command'  => 'dzil listdeps | cpanm -L perl5'
    }
};
my $app = sub { Sigma6->new($c)->run_psgi(@_) };

test_psgi $app, sub {
    my $cb = shift;
    {
        my $res = $cb->( GET "/" );
        is $res->code, 200, 'got a 200 for /';
        my $content = $res->content;

        like $content,
            qr|<title>Sigma6: git\@github.com:perigrin/sigma-6.git</title>|,
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
