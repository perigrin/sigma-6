package Sigma6::Plugin::Dzil;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Dist::Zilla Plugin

extends qw(Sigma6::Plugin);

has [
    qw(
        deps_command
        build_command
        )
] => ( isa => 'Str', is => 'ro', required => 1, );

with qw(Sigma6::Plugin::API::SmokeEngine);

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

Sigma6::Plugin::Dzil

=head1 SYNOPSIS

    [Dzil]
    deps_command  = cpanm -L perl5 --installdeps Makefile.PL
    build_command = prove -I perl5/lib/perl5 -lwrv t/

=head1 DESCRIPTION 

This Plugin implementes the SmokeEngine interface for L<Dist::Zilla> based
builds.

=head1 ROLES COMPOSED

=over 4

=item L<Sigma6::Plugin::API::SmokeEngine>

=back 

=head1 ATTRIBUTES

=over4 

=item deps_command

=item build_command

=back 

=head1 METHODS

=over 4

=item deps_command 

=item build_command

=item smoke_build

=back

