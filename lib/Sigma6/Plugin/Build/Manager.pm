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

sub check_all_builds {
    my $self = shift;
    return map { $self->check_build($_) } $self->list_build_ids;
}

sub check_build {
    my ( $self, $build_id ) = @_;
    my $build = $self->get_build($build_id);
    $build->status(
        $self->first_from_plugin_with(
            '-CheckSmoker' => sub { $_[0]->check_smoker($build) }
        )
    );
    $self->_set_build( $build_id => $build );
    return $build;
}

sub start_build {
    my ( $self, $build ) = @_;
    $build = $self->first_from_plugin_with('-BuildData' => sub { $_[0]->build_data($build) }) unless blessed($build);
    $build->id(
        $self->first_from_plugin_with(
            '-Repository' => sub { $_[0]->commit_id($build) }
        )
    );

    $build->description(
        $self->first_from_plugin_with(
            '-Repository' => sub { $_[0]->commit_description($build) }
        )
    );

    $self->_set_build( $build->{id} => $build );

    $self->first_from_plugin_with(
        '-EnqueueBuild' => sub { $_[0]->push_build($build) } );

    $self->first_from_plugin_with(
        '-StartSmoker' => sub { $_[0]->start_smoker() } );

    return $build;
}

1;
__END__
