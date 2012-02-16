package Sigma6::Plugin::CPAN;
1;
__END__
use Moose;
use namespace::autoclean;
use Sigma6::Model::Build;

# ABSTRACT: Sigma6 CPAN Plugin

extends qw(Sigma6::Plugin);

has [
    qw(
        deps_command
        build_command
        fetch_command
        )
] => ( isa => 'Str', is => 'ro', required => 1, );

with qw(
    Sigma6::Plugin::API::BuildData
    Sigma6::Plugin::API::Repository
    Sigma6::Plugin::API::SmokeEngine
);

sub build_data {
    my ( $self, $data ) = @_;
    confess 'Not Valid Build Data'
        unless Scalar::Util::reftype $data eq 'HASH';

    my $target = $data->{target} || return;
    return unless $target =~ m/::/;

    return Sigma6::Model::Build->new( 
            target => $target, 
        type => 'cpan' );

}

__PACKAGE__->meta->make_immutable;
1;
__END__
