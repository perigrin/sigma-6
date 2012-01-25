package Sigma6::Plugin::Git;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Git Plugin

use Git::Wrapper;

extends qw(Sigma6::Plugin);

has target => (
    isa     => 'Str',
    is      => 'rw',
    clearer => '_clear_target',
    trigger => sub {
        $_[0]->_clear_repository;
        $_[0]->_clear_workspace;
    },
);

has workspace => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_workspace',
    clearer => '_clear_workspace',
);

sub _build_workspace {
    shift->first_from_plugin_with( '-Workspace' => sub { shift->workspace } );
}

has repository => (
    isa       => 'Git::Wrapper',
    is        => 'rw',
    lazy      => 1,
    builder   => "_build_repository",
    clearer   => '_clear_repository',
    predicate => 'has_repository',
);

sub _build_repository {
    my $self = shift;
    my $git  = Git::Wrapper->new( $self->workspace );
    $git->clone( $self->target, $self->workspace );
    return $git;
}

with qw(
    Sigma6::Plugin::API::Repository
    Sigma6::Plugin::API::RecordResults
);

sub commit_id {
    my ( $self, $build_data ) = @_;
    $self->setup_repository($build_data) unless $self->has_repository;
    my ($sha1)
        = $self->repository->_cmd( 'ls-remote', $self->target, 'HEAD' );
    return substr( $sha1, 0, 7 );
}

sub commit_status {
    my ( $self, $build_data ) = @_;
    $self->setup_repository($build_data) unless $self->has_repository;
    $_[0]->repository->notes( 'show', 'HEAD' ) || '';
}

sub commit_description {
    my ( $self, $build_data ) = @_;
    $self->setup_repository($build_data) unless $self->has_repository;
    my ($desc) = $_[0]->repository->_cmd( 'log', '--oneline', '-1' );
    return $desc;
}

sub setup_repository {
    my ( $self, $build_data ) = @_;
    $self->target( $build_data->{'Git.target'} );
    $_[0]->repository->pull( 'origin', 'master' );
    $_[0]->repository->fetch( 'origin', 'refs/notes/*:refs/notes/*' );
}

sub teardown_repository {
    my $self = shift;
    $self->repository->push( 'origin', 'refs/notes/*' );
    $self->repository->clean('-dxf');
    $self->_clear_workspace;
    $self->_clear_repository;
}

sub record_results {
    my ( $self, $plugin ) = @_;
    return if $plugin == $self;
    $self->repository->notes( '--ref=sigma6 add -fm',  $plugin->build_status, 'HEAD' );
}

__PACKAGE__->meta->make_immutable;
1;
__END__
