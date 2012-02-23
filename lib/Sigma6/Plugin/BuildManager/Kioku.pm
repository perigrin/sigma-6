package Sigma6::Plugin::BuildManager::Kioku;
use Moose;
use namespace::autoclean;

# ABSTRACT: A KiokuDB Backed BuildManager Plugin

extends qw(Sigma6::Plugin);

use KiokuX::Model;
use Sigma6::Model::Build;

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
        get_build    => 'lookup',
        builds       => 'root_set',
        store_build  => 'store',
        update_build => 'update',
        clear_build  => 'delete',
    },
);

with qw(
    Sigma6::Plugin::API::BuildManager
    Sigma6::Plugin::API::RecordResults
);

for my $method (qw(get_build builds store_build update_build clear_build)) {
    around $method => sub {
        my $next  = shift;
        my $scope = $_[0]->model->new_scope;
        $next->(@_);
    };
}

sub check_all_builds {
    my $self  = shift;
    my $scope = $self->model->new_scope;
    $self->log( trace => 'BuildManager checking all builds' );
    return map { $self->check_build($_) } $self->builds->all;
}

sub check_build {
    my ( $self, $build ) = @_;
    $self->log( trace => 'BuildManager checking build' );
    $build->status(
        $self->first_from_plugin_with(
            '-CheckSmoker' => sub { $_[0]->check_smoker($build) }
        )
    );
    $self->update_build($build);
    return $build;
}

sub start_build {
    my ( $self, $stub ) = @_;
    $self->log( trace => 'BuildManager starting build' );

    $self->log( trace => 'BuildManager setting $build->revision' );

    my $revision = $self->first_from_plugin_with(
        '-Repository' => sub { $_[0]->revision($stub) } );

    $self->log( trace => 'BuildManager setting $build->description' );
    my $description = $self->first_from_plugin_with(
        '-Repository' => sub { $_[0]->revision_description($stub) } );

    my $build = Sigma6::Model::Build->new(
        type        => $stub->type,
        target      => $stub->target,
        revision    => $revision,
        description => $description,
    );

    $self->log( trace => 'BuildManager storing $build' );
    $self->store_build( $build->id => $build );

    $self->log( trace => 'BuildManager queueing $build' );
    $self->first_from_plugin_with(
        '-EnqueueBuild' => sub { $_[0]->push_build($build) } );

    $self->log( trace => 'BuildManager starting smoker' );
    $self->first_from_plugin_with(
        '-StartSmoker' => sub { $_[0]->start_smoker() } );

    return $build;
}

sub record_results {
    my ( $self, $build, $results ) = @_;
    $self->log( trace => 'BuildManager recording results' );
    $self->log( debug => $results );
    $build->status($results);
    $self->store_build($build);
    return;
}

1;
__END__

=head1 SYNOPSIS

    [BuildManager::Kioku]
    dsn = dbi:SQLite:builds.db

=head1 DESCRIPTION

This module implements the BuildManager API using a KiokuDB store for
persistence.

=head1 ROLES COMPOSED

=over 4

=item L<Sigma6::Plugin::API::BuildManager>

=item L<Sigma6::Plugin::API::RecordResults>

=back 

=head1 ATTRIBUTES

=over 4

=item dsn

=item model

=back

=head1 METHODS

=over4 

=item 

=item dsn

=item model

=item get_build

=item builds

=item store_build 

=item update_build

=item clear_build 

=item check_all_builds

=item check_build

=item start_build

=item record_results

=back
