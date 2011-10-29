#!/usr/bin/env perl
use strict;
use Test::More;
use Test::Deep;

BEGIN { use_ok('Sigma6::Config::GitLike'); }

ok( my $c = Sigma6::Config::GitLike->new(),
    'got new Sigma6::Config::GitLike'
);

ok( $c->load('t/etc/'), 'loaded the file okay' );
is( $c->confname,  'sigma6.ini',         'right default confname' );
is( $c->user_file, "$ENV{HOME}/.sigma6", 'user_file looks right' );

is_deeply(
    $c->config_files,
    [ grep { -f $_ } ( $c->global_file, $c->user_file, 't/etc/sigma6.ini' ) ],
    'config files looks right'
);

diag join ',', @{ $c->config_files };

# plugins
ok( $c->plugins, 'got plugns' );

for my $o ( @{ $c->plugins } ) {
    ok( $o->isa('Sigma6::Plugin') );
}

ok( $c->build_target,   'got a build target' );
ok( $c->smoker_command, 'got a smoker_command' );
ok( $c->temp_dir,       'got a temp directory' );

done_testing;
__END__
