#!/usr/bin/env perl
use strict;
use Test::More;

use Sigma6::Config::Gitlike;
use Sigma6::Plugin::Build::Manager;

my $c = Sigma6::Config::GitLike->new();
$c->load('t/etc/');



done_testing;
