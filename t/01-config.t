#!/usr/bin/env perl
use strict;
use Test::More;
use Test::Deep;

use Sigma6::Config::GitLike;

ok( my $c = Sigma6::Config::GitLike->new(),
    'got new Sigma6::Config::GitLike'
);

ok( $c->load('t/etc/'), 'loaded the file okay' );
is( $c->confname,  'sigma6.ini',         'right default confname' );
is( $c->user_file, "$ENV{HOME}/.sigma6", 'user_file looks right' );

is_deeply(
    $c->config_files,
    [ grep { -f $_ } ( $c->global_file, $c->user_file, "$ENV{PWD}/t/etc/sigma6.ini" ) ],
    'config files looks right'
);

ok( $c->plugins, 'got plugns' );

for my $o ( @{ $c->plugins } ) {
    ok( $o->isa('Sigma6::Plugin'), "$o isa Sigma6::Plugin" );
}

done_testing;
__END__
