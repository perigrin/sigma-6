package Sigma6::Smoker;
use Moose;
use namespace::autoclean;

# ABSTRACT: The Smoke Driver for Sigma6.

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
);

has build_data => (
    isa       => 'Ref',
    is        => 'ro',
    clearer   => 'clear_build_data',
    predicate => 'has_build_data',
    lazy      => 1,
    default   => sub {
        my $self = shift;
        my $data = $self->first_from_plugin_with(
            '-DequeueBuild' => sub { $_[0]->fetch_build } );
        $self->log( debug => "Data: $data" );
        $self->log( die => "No Data!" ) unless $data;
        return $data;
    }
);

sub log {
    my ( $self, $level, $message ) = @_;
    for ( $self->plugins_with('-Logger') ) {
        $_->$level($message);
    }
}

sub setup_workspace {
    my ($self) = @_;
    $self->log( trace => 'Smoker setting up workspace' );
    $_->setup_workspace( $self->build_data )
        for $self->plugins_with('-SetupWorkspace');
}

sub setup_repository {
    my ($self) = @_;
    $self->log( trace => 'Smoker setting up repository ' . $self->build_data->target );
    for ( $self->plugins_with('-SetupRepository') ) {
        $_->setup_repository( $self->build_data );
    }
}

sub setup_smoker {
    my ($self) = @_;
    $self->log( trace => 'Smoker setting up smoker ' . $self->build_data->target );
    $_->setup_smoker( $self->build_data )
        for $self->plugins_with('-SetupSmoker');
}

sub run_smoker {
    my ($self) = @_;
    $self->log( trace => 'Smoker running smoker ' . $self->build_data->target );
    $_->run_smoke( $self->build_data ) for $self->plugins_with('-RunSmoker');
}

sub record_results {
    my ($self) = @_;
    $self->log( trace => 'Smoker recording results ' . $self->build_data->target );
    for my $smoker ( $self->plugins_with('-CheckSmoker') ) {
        for my $logger ( $self->plugins_with('-RecordResults') ) {
            my $build   = $self->build_data;
            my $results = $smoker->check_smoker( $self->build_data );
            $logger->record_results( $build, $results );
        }
    }
}

sub teardown_smoker {
    my ($self) = @_;
    $self->log( trace => 'Smoker tearing down smoker ' . $self->build_data->target );
    $_->teardown_smoker( $self->build_data )
        for $self->plugins_with('-TeardownSmoker');
}

sub teardown_workspace {
    my ($self) = @_;
    $self->log( trace => 'Smoker tearing down workspace ' . $self->build_data->target );
    $_->teardown_workspace( $self->build_data )
        for $self->plugins_with('-TeardownWorkspace');
}

sub teardown_repository {
    my ($self) = @_;
    $self->log( trace => 'Smoker tearing down repository ' . $self->build_data->target );
    $_->setup_repository( $self->build_data )
        for $self->plugins_with('-TeardownRepository');
}

sub run {
    my $self = shift;
    $self->log( trace => 'Smoker starting run ' . $self->build_data->target );
    $self->setup_workspace;
    $self->setup_repository;
    $self->setup_smoker;
    $self->run_smoker;
    $self->record_results;
    $self->teardown_smoker;
    $self->teardown_repository;
    $self->teardown_workspace;
    $self->log( trace => 'Smoker ending run ' . $self->build_data->target );
    $self->clear_build_data;
}

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME 

Sigma6::Smoker

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

=head1 DESCRIPTION

This is the main driver for the backend of Sigma6. This drives the smoking process. 

=head1 EVENTS

This is the sequence of events that the Smoker runs through on each build.
Each of these events is called on the plugins that perform the corresponding
APIs.

=over 4

=item setup_workspace

Calls C<setup_workspace> with the current build instance on anything that does
C<SetupWorkspace>.

=item setup_repository

Calls C<setup_repository> with the current build instanceon anything that does
C<SetupRepository>.

=item setup_smoker

Calls C<setup_smoker> with the current build instance on anything that does
C<SetupSmoker>.

=item run_smoker

Calls C<run_smoke> with the current build instance on anything that does
C<RunSMoker>

=item record_results

With the output of each plugin that does C<CheckSmoker>, it calls
C<record_results> on all plugins that do C<RecordResults>.

=item teardown_smoker

Calls C<teardown_smoker> with the current build instance on anything that does
C<TeardownSmoker>.

=item teardown_repository

Calls C<teardown_repository> with the current build instanceon anything that does
C<TeardownRepository>.

=item teardown_workspace

Calls C<teardown_workspace> with the current build instance on anything that does
C<TeardownWorkspace>.

=back
