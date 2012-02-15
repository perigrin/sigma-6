package Sigma6::Plugin::Build::Manager;
use 5.10.1;
use Moose;
use namespace::autoclean;

extends qw(Sigma6::Plugin);

with qw(Sigma6::Plugin::API::BuildManager);

use KiokuX::Model;

has dsn => (
    isa     => 'Str',
    is      => 'ro',
    default => 'dbi:SQLite::memory:',
);

has model => (
    isa     => 'KiokuX::Model',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        KiokuX::Model->new(
            dsn        => shift->dsn,
            extra_args => { create => 1 },
        );
    },
    handles => {
       get_build     => 'lookup',
        _builds        => 'root_set',
        _store_build  => 'store',
        _update_build => 'update',
    },
);

around get_build => sub { 
        my $next = shift;
        my $scope = $_[0]->model->new_scope;
        $next->(@_);
};

sub check_all_builds {
    my $self = shift;
    my $scope = $self->model->new_scope;
    return map { $self->check_build($_) } $self->_builds->all;
}

sub check_build {
    my ( $self, $build ) = @_;
    my $scope = $self->model->new_scope;
    $build->status(
        $self->first_from_plugin_with(
            '-CheckSmoker' => sub { $_[0]->check_smoker($build) }
        )
    );
    $self->_update_build( $build );
    return $build;
}

sub start_build {
    my ( $self, $build ) = @_;
    my $scope = $self->model->new_scope;
    $self->warn('BuildManager Starting Build');
    $build
        = $self->first_from_plugin_with(
        '-BuildData' => sub { $_[0]->build_data($build) } )
        unless blessed($build);
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
    $self->_store_build( $build->id => $build );

    $self->first_from_plugin_with(
        '-EnqueueBuild' => sub { $_[0]->push_build($build) } );

    $self->first_from_plugin_with(
        '-StartSmoker' => sub { $_[0]->start_smoker() } );

    return $build;
}

1;
__END__
