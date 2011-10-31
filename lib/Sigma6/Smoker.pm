package Sigma6::Smoker;
use Moose;

use Capture::Tiny qw(capture_merged);

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
);

has build_output => (
    isa     => 'Str',
    is      => 'ro',
    traits  => ['String'],
    handles => { append_build_output => 'append' },
    default => '',
);

sub setup_repository {
    my ($self) = @_;
    $_->setup_repository for $self->plugins_with('-SetupRepository');
}

sub setup_workspace {
    my ($self) = @_;
    $_->setup_workspace for $self->plugins_with('-SetupWorkspace');
}

sub run_build {
    my ($self) = @_;
    for my $plugin ( $self->plugins_with('-RunBuild') ) {
        $self->append_build_output(
            capture_merged sub {
                system $plugin->deps_command;
                system $plugin->build_command;
            }
        );
    }
}

sub teardown_workspace {
    my ($self) = @_;
    $_->teardown_workspace for $self->plugins_with('-TeardownWorkspace');
}

sub log_results {
    my ( $self, ) = @_;
    $_->log_results( $self->build_output )
        for $self->plugins_with('-LogOutput');
}

sub run {
    my $self = shift;
    $self->setup_repository;
    $self->initialize_workspace;
    $self->run_build;
    $self->teardown_workspace;
    $self->log_results;
}

__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME Sigma6::Smoke

=head1 SYNOPSIS

    my $smoker = Sigma6::Smoke->new(
        target        => 'git@github.com:perigrin/sigma-6.git',
        temp_dir      => '/tmp/sigma6',
        deps_command  => 'dzil listdeps | cpanm -L perl5',
        build_command => 'dzil smoke --automated',
    );
    $smoker->run();

=head1 DESCRIPTION

The default smoker for Sigma6. 
