package Sigma6::Plugin::Git;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Git Plugin

use Git::Repository;

extends qw(Sigma6::Plugin);

has repository => (
    isa     => 'Git::Repository',
    is      => 'ro',
    lazy    => 1,
    clearer => '_clear_repository',
    builder => "_build_repository",
    handles => { git_run => 'run', }
);

sub _build_repository {
    my $self = shift;
    unless ( -e $self->workspace ) {
        Git::Repository->run( clone => $self->target => $self->workspace );
    }
    Git::Repository->new( work_tree => $self->workspace );
}

with qw(
    Sigma6::Plugin::API::SetupRepository
    Sigma6::Plugin::API::Repository
    Sigma6::Plugin::API::TeardownRepository
    Sigma6::Plugin::API::BuildStatus
    Sigma6::Plugin::API::RecordResults
);

has workspace => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    clearer => '_clear_workspace',
    builder => '_build_workspace',
);

sub _build_workspace {
    my $self = shift;
    $self->first_from_plugin_with( '-Workspace', sub { shift->workspace } );
}

sub target {
    $_[0]->get_config( key => 'git.target' );
}

sub build_id {
    my $self = shift;
    my $sha1 = Git::Repository->run( 'ls-remote', $self->target, 'HEAD' );
    return substr( $sha1, 0, 7 );
}

sub build_status {
    $_[0]->git_run( 'notes', 'show', 'HEAD' ) || '';
}

sub build_description {
    $_[0]->git_run( 'log', '--oneline', '-1' );
}

sub setup_repository {
    $_[0]->git_run('pull');
    $_[0]->git_run( 'fetch', 'origin', 'refs/notes/*:refs/notes/*' );
}

sub teardown_repository {
    my $self = shift;
    $self->git_run( 'push', 'origin', 'refs/notes/*' );
    $self->git_run( 'clean', '-dxf' );
    $self->_clear_workspace;
    $self->_clear_repository;
}

sub record_results {
    my ( $self, $plugin ) = @_;
    return if $plugin == $self;
    $self->git_run( 'notes', '--ref=sigma6', 'add', '-fm',
        $plugin->build_status, 'HEAD' );
}

__PACKAGE__->meta->make_immutable;
1;
__END__
