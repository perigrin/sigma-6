#!/usr/bin/env perl
use strict;

use Test::More;

{
    package Sigma6::Config::Simple;
    use Moose;

    with qw(Sigma6::Config);
}





done_testing();
