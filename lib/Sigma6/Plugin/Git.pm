package Sigma6::Plugin::Git;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Git Plugin

use Git::Wrapper;
use Try::Tiny;
use Sigma6::Model::Build;

extends qw(Sigma6::Plugin);

with qw(
    Sigma6::Plugin::API::BuildData
    Sigma6::Plugin::API::Repository
);

sub build_data {
    my ( $self, $data ) = @_;
    confess 'Not Valid Build Data'
        unless Scalar::Util::reftype $data eq 'HASH';

    my $target = $data->{target} || return;

    return unless $target =~ m/^git@|\.git/;

    return Sigma6::Model::Build->new(
        target => $target,
        type   => 'git'
    );

}

sub target {
    my ( $self, $build ) = @_;
    $self->log( trace => "Git build target $build->{target}" );
    $self->die("Unblessed build: $build") unless blessed($build);
    return $build->target;
}

sub workspace {
    my ( $self, $build ) = @_;
    $self->first_from_plugin_with( '-Workspace' => sub { shift->workspace } );
}

sub humanish {
    my ( $self, $target ) = @_;
    return unless $target;
    for ($target) {
        s|/$||;
        s|:*/*\.git$||;
        s|.*/||g;
    }
    return $target;
}

sub repository {
    my ( $self, $build ) = @_;
    $self->log( trace => 'Git repository' );
    my $target = $self->target($build);
    my $dir    = $self->humanish($target);
    $self->log( trace => "Git building Git::Wrapper for $dir" );
    my $git = Git::Wrapper->new( $self->workspace . '/' . $dir );
    $git->clone( $target => $git->dir ) unless -e $git->dir;
    $git->fetch();
    return $git;
}

sub revision {
    my ( $self, $build ) = @_;
    $self->log( trace => 'Git revision id' );
    return $build->revision if $build->revision;
    my $target = $self->target($build);
    my $repo   = $self->repository($build);
    my ($sha1) = $repo->_cmd( 'ls-remote', $target, 'HEAD' );
    $self->log( trace => "Git revision id $sha1" );
    return substr( $sha1, 0, 7 );
}

sub revision_status {
    my ( $self, $build ) = @_;
    $self->log( trace => 'Git commit status' );
    $self->repository($build)->notes( 'show', 'HEAD' ) || '';
}

sub revision_description {
    my ( $self, $build ) = @_;
    $self->log( trace => 'Git commit description' );
    my $repo = $self->repository($build);
    my ($desc) = $repo->_cmd( 'log', '--oneline', '-1' );
    my $revision = $self->revision($build);
    $desc =~ s/^\Q$revision\E//;
    return $desc;
}

sub setup_repository {
    my ( $self, $build ) = @_;
    $self->log( trace => 'Git setup repository' );
    $self->repository($build)->pull( 'origin', 'master' );
    $self->repository($build)->fetch( 'origin', 'refs/notes/*:refs/notes/*' );
}

sub teardown_repository {
    my ( $self, $build ) = @_;
    $self->log( trace => 'Git teardown repository' );
    $self->repository($build)->push( 'origin', 'refs/notes/*' );
    $self->repository($build)->clean('-dxf');
}

sub repository_directory {
    my ( $self, $build ) = @_;
    $self->log( trace => 'Git teardown repository' );
    $self->repository($build)->dir;
}

sub record_results {
    my ( $self, $build, $results ) = @_;
    $self->log( 'debug' => "git notes --ref=sigma6 add -fm '$results' HEAD" );
    $self->repository($build)
        ->notes( '--ref=sigma6 add -fm', "'$results'", 'HEAD' );
}

__PACKAGE__->meta->make_immutable;
1;
__END__
