package Sigma6::Plugin::Build::Manager;
use 5.10.1;
use Moose;
use namespace::autoclean;

extends qw(Sigma6::Plugin);

with qw(Sigma6::Plugin::API::BuildManager);

has builds => (
    isa     => 'HashRef',
    traits  => ['Hash'],
    default => sub { {} },
    handles => {
        _set_build     => 'set',
        get_build      => 'get',
        list_build_ids => 'keys',
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

sub check_all_builds {
    my $self = shift;
    return map { $self->check_build($_) } $self->list_build_ids;
}

sub check_build {
    my ( $self, $build_id ) = @_;
    my $build_data = $self->get_build($build_id);
    $build_data->{status} = $self->first_from_plugin_with(
        '-CheckSmoker' => sub { $_[0]->check_smoker($build_data) } );
    $self->_set_build( $build_id => $build_data );
    return $build_data;
}

sub start_build {
    my ( $self, $build_data ) = @_;

    $build_data->{description} //= $self->build_description($build_data);
    $build_data->{id} = $self->build_id($build_data);

    $self->_set_build( $build_data->{id} => $build_data );

    $self->first_from_plugin_with(
        '-EnqueueBuild' => sub { $_[0]->push_build($build_data) } );

    $self->first_from_plugin_with(
        '-StartSmoker' => sub { $_[0]->start_smoker } );

    return $build_data->{id};
}

1;
__END__
