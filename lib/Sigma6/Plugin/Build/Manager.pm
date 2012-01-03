package Sigma6::Plugin::Build::Manager;
use Moose;
use namespace::autoclean;

extends qw(Sigma6::Plugin);

with qw(
    Sigma6::Plugin::API::CheckBuild
    Sigma6::Plugin::API::StartBuild
);

sub build_id {
    my $self = shift;
    $self->first_from_plugin_with( '-Repository' => sub { $_[0]->build_id } );
}

sub build_description {
    my $self = shift;
    $self->first_from_plugin_with(
        '-Repository' => sub { $_[0]->build_description } );
}

sub build_target {
    shift->first_from_plugin_with( '-Repository' => sub { $_[0]->target } );
}

sub check_all_builds {
    my $self = shift;
    return {
        id          => $self->build_id,
        description => $self->build_description,
        status      => $self->check_build,
        target      => $self->build_target,
    };
}

sub check_build {
    shift->first_from_plugin_with(
        '-CheckSmoker' => sub { $_[0]->smoker_status } );
}

sub start_build {
    my ( $self, $build_data ) = @_;

    $self->first_from_plugin_with(
        '-Queue' => sub { $_[0]->push_build($build_data) } );

    $self->first_from_plugin_with(
        '-StartSmoker' => sub { $_[0]->start_smoker } );

    return $build_data;
}

1;
__END__
