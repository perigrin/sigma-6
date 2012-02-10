package Sigma6::Plugin::Git;
use v5.10.1;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Git Plugin

use Git::Wrapper;
use Try::Tiny;
use Sigma6::Model::Build;

sub Build() {'Sigma6::Model::Build'}

extends qw(Sigma6::Plugin);

with qw(
    Sigma6::Plugin::API::BuildData
    Sigma6::Plugin::API::Repository
    Sigma6::Plugin::API::RecordResults
);

sub build_data {
    my ( $self, $data ) = @_;
    confess 'Not Valid Build Data'
        unless Scalar::Util::reftype $data eq 'HASH';

    my $target = $data->{target} || return;

    return unless $target =~ m/^git@|\.git/;

    return Build->new(
        target => $target,
        type   => 'git'
    );

}

sub target {
    my ( $self, $build ) = @_;
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
    my $target = $self->target($build);
    my $dir    = $self->humanish($target);
    my $git    = Git::Wrapper->new( $self->workspace . '/' . $dir );
    $git->clone( $target => $git->dir ) unless -e $git->dir;
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
    $self->repository($build)->notes( 'show', 'HEAD' ) || '';
}

sub commit_description {
    my ( $self, $build ) = @_;
    my $repo = $self->repository($build);
    my ($desc) = $repo->_cmd( 'log', '--oneline', '-1' );
    return $desc;
}

sub setup_repository {
    my ( $self, $build ) = @_;
    $self->repository($build)->pull( 'origin', 'master' );
    $self->repository($build)->fetch( 'origin', 'refs/notes/*:refs/notes/*' );
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
