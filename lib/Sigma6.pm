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
    handles => ['as_psgi'],
);

sub _build_web_app { Sigma6::Web->new( config => shift->config ) }

1;
__END__
=head1 NAME 

Sigma6

=head1 SYNOPSIS

    > curl -L https://raw.github.com/perigrin/sigma-6/master/bin/install.sh | bash
    
    > cat sigma6.ini
    [BuildManager::Kioku]
    [JSON]

    [Queue::Mmap]
    file        = /tmp/sigma6/queue.dat
    size        = 10
    record_size = 20
    mode        = 0666

    [Smoker::Simple]
    workspace      = /tmp/sigma6/test
    smoker_command = bin/smoker.pl --config etc/sigma6.ini

    [Git]
    note_command  = notes --ref=sigma6-test add -fm

    [Github]

    [Dzil]
    deps_command  = cpanm -L perl5 --installdeps Makefile.PL
    build_command = prove -I perl5/lib/perl5 -lwrv t/ 

    > plackup app.psgi

=head1 DESCRIPTION

Sigma6 is a Continuous Integration application originally based upon
CIJoe. It's built around a plugin system inspired by Dist::Zilla.

=head1 GETTING STARTED

Before you get started you will need to have a copy of L<Perl> 5.10.0 or
higher installed, a copy of C<git>.

    curl -L https://raw.github.com/perigrin/sigma-6/master/bin/install.sh | bash

or if you have wget

    wget --no-check-certificate -O https://raw.github.com/perigrin/sigma-6/master/bin/install.sh | bash

Once this process completes you'll have a L<local::lib> installed copy of Sigma6.

At this point simply run L<plackup> to fire up the server.

    perl5/bin/localenv-bashrc plackup


=head1 ARCHITECTURE

=over 4

=item L<Sigma6::Web> The Web Frontend

C<Sigma6::Web> provides a REST API for adding, removing, and querying builds
in the system. It also come bundled with a basic HTML/JS client.

=item L<Sigma6::Config> The Configuration/Plugin System

The configuration system is inspired by teh Dist::Zilla plugin system. Plugins
conform to specific APIs defined in the L<Sigma6::Plugin::API> namespace.
Plugins are then called at each stage of the smoke process.

=item L<Sigma6::Smoker> The Smoke Engine

The Smoke engine handles pulling down a repository from a remote location,
testing teh build, and reporting the results.

=back

=head1 SPECIAL THANKS

Portions of Sigam6's development (like the entire Plugin System) were
funded by SocialFlow. Special thanks go out to them.
