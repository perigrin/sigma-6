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
