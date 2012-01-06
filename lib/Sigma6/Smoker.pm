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

has build_data => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    builder => 'fetch_build_data'
);

sub fetch_build_data {
    my $self = shift;
    my $data;
    $self->first_from_plugin_with(
        '-DeQueue' => sub { $data = $_[0]->shift_build } );
    return $data;
}

sub setup_repository {
    my ($self) = @_;
    $_->setup_repository( $self->build_data )
        for $self->plugins_with('-SetupRepository');
}

sub setup_workspace {
    my ($self) = @_;
    $_->setup_workspace( $self->build_data )
        for $self->plugins_with('-SetupWorkspace');
}

sub setup_smoker {
    my ($self) = @_;
    $_->setup_smoker( $self->build_data )
        for $self->plugins_with('-SetupSmoker');
}

sub run_smoker {
    my ($self) = @_;
    $_->run_smoke( $self->build_data ) for $self->plugins_with('-RunSmoker');
}

sub record_results {
    my ($self) = @_;
    for my $build ( $self->plugins_with('-CheckSmoker') ) {
        for my $logger ( $self->plugins_with('-RecordResults') ) {
            $logger->record_results($build);
        }
    }
}

sub teardown_smoker {
    my ($self) = @_;
    $_->teardown_workspace( $self->build_data )
        for $self->plugins_with('-TeardownSmoker');
}

sub teardown_workspace {
    my ($self) = @_;
    $_->teardown_workspace( $self->build_data )
        for $self->plugins_with('-TeardownWorkspace');
}

sub teardown_repository {
    my ($self) = @_;
    $_->setup_repository( $self->build_data )
        for $self->plugins_with('-TeardownRepository');
}

sub run {
    my $self = shift;
    $self->fetch_build_data;
    $self->setup_repository;
    $self->setup_workspace;
    $self->setup_smoker;
    $self->run_smoker;
    $self->record_results;
    $self->teardown_smoker;
    $self->teardown_workspace;
    $self->teardown_repository;
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

