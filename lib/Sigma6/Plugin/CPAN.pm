package Sigma6::Plugin::CPAN;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 CPAN Plugin

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
