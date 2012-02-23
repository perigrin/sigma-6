package Sigma6::Plugin::Smoker::Simple;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Smoker Plugin using simple Unix systems calls.

use Cwd qw(chdir getcwd);

extends qw(Sigma6::Plugin);

has previous_workspace => (
    isa     => 'Str',
    is      => 'ro',
    default => sub { getcwd() },
);

has workspace => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

has smoker_command => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

with qw(
    Sigma6::Plugin::API::Smoker
    Sigma6::Plugin::API::Workspace
);

has deps_file => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_deps_file',
);

sub _build_deps_file {
    my $dir = shift->workspace;
    return "$dir/.sigma6/deps.output";
}

has build_file => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_build_file',
);

sub _build_build_file {
    my $dir = shift->workspace;
    "$dir/.sigma6/deps.output";
}

sub check_smoker {
    my $self = shift;
    $self->log( trace => 'Smoker::Simple check smoker' );

    my $output;
    for my $file ( $self->deps_file, $self->build_file ) {
        next unless -e $file;
        $output .= `cat $file`;
    }
    return $output if $output;
    return '[nothing yet]';
}

sub start_smoker {
    my $self = shift;
    my $cmd  = $self->smoker_command;
    $self->die('No smoker_command') unless $cmd;
    $self->log( trace => 'Smoker::Simple starting smoker' );
    if ( my $pid = fork ) {
        $self->warn("forked smoker as $pid");
        return $pid;
    }
    elsif ( defined $pid ) {
        $self->warn("starting smoker `$cmd` as $pid");
        exec( 'bin/smoker.pl', '--config sigma6.ini' )
            or $self->die("Could not start `$cmd`: $!");
        exit;
    }
    else {
        $self->die("Could not fork: $!");
    }
}

sub setup_smoker    { }
sub teardown_smoker { }

sub repository_directory {
    my ( $self, $build ) = @_;
    $self->first_from_plugin_with( '-Repository',
        sub { shift->repository_directory($build) } );
}

sub run_smoke {
    my ( $self, $build ) = @_;
    my $deps_file  = $self->deps_file;
    my $build_file = $self->build_file;
    
    $self->log( trace => 'Smoker::Simple run smoke' );
    chdir $self->repository_directory($build);
    $self->first_from_plugin_with(
        '-SmokeEngine' => sub {
            $_[0]->smoke_build(
                $build => sub {
                    my ( $self, $build ) = @_;
                    my $deps_command  = $self->deps_command;
                    my $build_command = $self->build_command;
                    system 'mkdir .sigma6' unless -e '.sigma6';
                    system "$deps_command &> $deps_file";
                    system "$build_command &> $build_file";
                },
            );
        }
    );
}

sub teardown_smoke { }

sub setup_workspace {
    my ( $self, $build_data ) = @_;
    $self->log( trace => 'Smoker::Simple setup workspace ' );
    mkdir $self->workspace unless -e $self->workspace;
    chdir $self->workspace;
    $ENV{PERL5LIB} .= ':perl5/lib/perl5';
}

sub teardown_workspace {
    my $self = shift;
    $self->log( trace => 'Smoker::Simple teardown workspace ' );
    chdir $self->previous_workspace;
}

__PACKAGE__->meta->make_immutable;
1;
__END__
<<<<<<< HEAD
=======

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ROLES COMPOSED

=over 4

=item L<Sigma6::Plugin::API::Smoker>

=item L<Sigma6::Plugin::API::Workspace>

=back

=head1 ATTRIBUTES

=over 4

=item previous_workspace 

=item workspace

=item smoker_command

=item deps_file

=item build_file

=back

=head1 METHODS

=over4

=item previous_workspace

=item workspace

=item smoker_command

=item deps_file

=item build_file

=item check_smoker

=item start_smoker

=item setup_smoker

=item teardown_smoker

=item repository_directory

=item run_smoke

=item teardown_smoke

=item setup_workspace

=item teardown_workspace

=back

