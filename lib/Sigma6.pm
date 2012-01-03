package Sigma6;
use v5.10;
use Moose;

# ABSTRACT: CIJoe is a Real American Hero ... Sigma6 continues the battle against Pyth^WCobra

use Sigma6::Config;
use Sigma6::Web;

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
);

has web_app => (
    isa     => 'Sigma6::Web',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_web_app',
    handles => ['run_psgi'],
);

sub _build_web_app { Sigma6::Web->new( config => shift->config ) }

1;
__END__

=head1 NAME Sigma6

CIJoe is a Real American Hero ... Sigma6 continues the battle against Pyth^WCobra

=head1 SYNOPSIS

    > cat sigma6.ini
    [System]
    temp_dir       = /tmp/sigma6
    smoker_command = bin/smoker.pl;

    [Git]
    target        = git@github.com:perigrin/sigma-6.git

    [Dzil]
    deps_command  = dzil listdeps | cpanm -L perl5
    build_command = 'PERL5LIB="perl5/lib/perl5:$PERL5LIB" dzil smoke'
        
    > plackup app.psgi

=head1 DESCRIPTION

Sigma6 is a Continuous Integration application originally based upon
CIJoe. It should be self-hosting now but that hasn't really been pushed.
Additionally the tests are woefully lacking, and you're reading all of the
documentation there is. That said, it's 531 lines of code, you could
just read that.

=head1 THANKS

Portions of Sigam6's development (like the entire Plugin System) were
funded by SocialFlow. Special thanks go out to them.

