package Sigma6::Plugin::Git;
use Moose;
use namespace::autoclean;

use Git::Repository;

extends qw(Sigma6::Plugin);

with qw(
    Sigma6::Plugin::API::BuildTarget
    Sigma6::Plugin::API::SetupRepository
);

has repo => (
    isa     => 'Git::Repository',
    is      => 'ro',
    lazy    => 1,
    builder => "_build_repo",
    handles => { git_run => 'run', }
);

sub _build_repo {
    my $self = shift;
    unless ( -e $self->temp_dir ) {
        Git::Repository->run(
            clone => $self->build_target => $self->temp_dir );
    }
    return Git::Repository->new( work_tree => $self->temp_dir );
}

sub build_target {
    my $self = shift;
    return $self->get_config( key => 'git.target' );
}

sub check_build {
    my ($self) = @_;
    $self->setup_repository;

    return +{
        head_sha1 => substr( $self->git_run( 'rev-parse' => 'HEAD' ), 0, 7 ),
        status => $self->git_run( 'notes', 'show', 'HEAD' ) || '',
        description => $self->git_run( 'log', '--oneline', '-1' ),
    };
}

sub setup_repository {
    my ($self) = @_;
    $self->git_run('pull');
}

sub log_results {
    my ( $self, $results ) = @_;
    $self->git_run( 'notes', 'add', '-fm', $results, 'HEAD' );
}

__PACKAGE__->meta->make_immutable;
1;
__END__
