package Sigma6::Plugin::Git;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Git Plugin

use Git::Wrapper;
use Try::Tiny;

extends qw(Sigma6::Plugin);

with qw(
    Sigma6::Plugin::API::Repository
    Sigma6::Plugin::API::RecordResults
);

sub target {
    my ( $self, $build ) = @_;
    confess 'No Git.target key' unless exists $build->{'Git.target'};
    return $build->{'Git.target'};
}

sub workspace {
    my ( $self, $build ) = @_;
    $self->first_from_plugin_with( '-Workspace' => sub { shift->workspace } );
}

sub repository {
    my ( $self, $build ) = @_;
    my $git = Git::Wrapper->new( $self->workspace . '/' );
    $git->clone( $self->target($build) => $git->dir ) unless -e $git->dir;
    return $git;
}

sub commit_id {
    my ( $self, $build ) = @_;
    my $target = $self->target($build);
    my $repo   = $self->repository($build);
    my ($sha1) = $repo->_cmd( 'ls-remote', $target, 'HEAD' );
    return substr( $sha1, 0, 7 );
}

sub commit_status {
    my ( $self, $build ) = @_;
    $_[0]->repository($build)->notes( 'show', 'HEAD' ) || '';
}

sub commit_description {
    my ( $self, $build ) = @_;
    my ($desc) = $_[0]->repository($build)->_cmd( 'log', '--oneline', '-1' );
    return $desc;
}

sub setup_repository {
    my ( $self, $build ) = @_;
    $_[0]->repository($build)->pull( 'origin', 'master' );
    $_[0]->repository($build)->fetch( 'origin', 'refs/notes/*:refs/notes/*' );
}

sub teardown_repository {
    my ( $self, $build ) = @_;
    $self->repository($build)->push( 'origin', 'refs/notes/*' );
    $self->repository($build)->clean('-dxf');
}

sub record_results {
    my ( $self, $plugin, $build ) = @_;
    return if $plugin == $self;
    $self->repository($build)->notes( '--ref=sigma6 add -fm',
        $plugin->build_status($build), 'HEAD' );
}

__PACKAGE__->meta->make_immutable;
1;
__END__
