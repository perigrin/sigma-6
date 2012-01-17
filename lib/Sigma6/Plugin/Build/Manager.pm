package Sigma6::Plugin::Build::Manager;
use Moose;
use namespace::autoclean;

extends qw(Sigma6::Plugin);

with qw(Sigma6::Plugin::API::BuildManager);

has builds => (
    isa     => 'HashRef',
    traits  => ['Hash'],
    default => sub { {} },
    handles => {
        add_build      => 'set',
        get_build      => 'get',
        remove_build   => 'delete',
        list_build_ids => 'keys'
    }
);

sub build_id {
    my ( $self, $build_data ) = @_;
    $self->first_from_plugin_with(
        '-Repository' => sub { $_[0]->commit_id($build_data) } );
}

sub build_description {
    my ( $self, $build_data ) = @_;
    $self->first_from_plugin_with(
        '-Repository' => sub { $_[0]->commit_description($build_data) } );
}

sub build_target {
    shift->first_from_plugin_with( '-Repository' => sub { $_[0]->target } );
}

sub smoker_status {
    my ( $self, $build_data ) = @_;
    $self->first_from_plugin_with(
        '-CheckSmoker' => sub { $_[0]->smoker_status($build_data) } );
}

sub check_all_builds {
    my $self = shift;
    return map { $self->check_build($_) } $self->list_build_ids;
}

sub check_build {
    my ( $self, $build_id ) = @_;
    my $build_data = $self->get_build($build_id);
    return {
        id          => $self->build_id($build_data),
        description => $self->build_description($build_data),
        target      => $self->build_target($build_data),
        status      => $self->smoker_status($build_data),
    };
}

sub start_build {
    my ( $self, $build_data ) = @_;

    $build_data->{build_id} = $self->build_id($build_data);
    $self->add_build( $build_data->{build_id} => $build_data );

    $self->first_from_plugin_with(
        '-Queue' => sub { $_[0]->push_build($build_data) } );

    $self->first_from_plugin_with(
        '-StartSmoker' => sub { $_[0]->start_smoker } );

    return $build_data->{build_id};
}

1;
__END__
