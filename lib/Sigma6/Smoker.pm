package Sigma6::Smoker;
use Moose;
use namespace::autoclean;

# ABSTRACT: The Default Smoker for Sigma6

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
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
    $_->run_build for $self->plugins_with('-RunBuild');
}

sub teardown_workspace {
    my ($self) = @_;
    $_->teardown_workspace for $self->plugins_with('-TeardownWorkspace');
}

sub record_results {
    my ($self) = @_;
    for my $build ( $self->plugins_with('-BuildStatus') ) {
        for my $logger ( $self->plugins_with('-RecordResults') ) {
            $logger->record_results($build);
        }
    }
}

sub run {
    my $self = shift;
    $self->setup_repository;
    $self->setup_workspace;
    $self->run_build;
    $self->record_results;
    $self->teardown_workspace;
}

__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME Sigma6::Smoker

=head1 SYNOPSIS

    #!/usr/bin/env perl
    use strict;
    use warnings;
    use lib qw(lib);

    use Sigma6::Smoker;
    use Sigma6::Config::GitLike;

    my $c = Sigma6::Config::GitLike->new();
    $c->load( $ENV{PWD} );

    Sigma6::Smoker->new( config => $c )->run();

