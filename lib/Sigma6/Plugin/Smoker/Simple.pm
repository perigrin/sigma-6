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

sub deps_file {
    my ( $self, $build ) = @_;
    my $dir = $self->repository_directory($build);
    return "$dir/.sigma6/deps.output";
}

sub build_file {
    my ( $self, $build ) = @_;
    my $dir = $self->repository_directory($build);
    "$dir/.sigma6/build.output";
}

sub check_smoker {
    my ( $self, $build ) = @_;
    $self->log( trace => 'Smoker::Simple check smoker' );

    my $output;
    for my $file ( $self->deps_file($build), $self->build_file($build) ) {
        $self->log( trace => "Smoker::Simple checking smoker $file" );
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
        $self->warn("Smoker::Simple forked smoker as $pid");
        return $pid;
    }
    elsif ( defined $pid ) {
        $self->warn("Smoker::Simple starting smoker `$cmd` as $pid");
        exec( 'bin/smoker.pl', '--config sigma6.ini' )
            or $self->die("Could not start `$cmd`: $!");
        exit;
    }
    else {
        $self->die("Could not fork: $!");
    }
}

sub setup_smoker { }

sub teardown_smoker {
    my ( $self, $build ) = @_;
    $self->repository_directory($build) . '/.sigma6';
}

sub repository_directory {
    my ( $self, $build ) = @_;
    $self->first_from_plugin_with( '-Repository',
        sub { shift->repository_directory($build) } );
}

sub run_smoke {
    my ( $self, $build ) = @_;
    $self->log( trace => 'Smoker::Simple run smoke' );

    my $deps_file  = $self->deps_file($build);
    my $build_file = $self->build_file($build);
    my $dir        = $self->repository_directory($build);
    $self->log( trace => 'Smoke::Simple changing to ' . $dir );
    chdir $dir;
    $self->first_from_plugin_with(
        '-SmokeEngine' => sub {
            $_[0]->smoke_build(
                $build => sub {
                    my ( $self, $build ) = @_;
                    my $deps_command  = $self->deps_command;
                    my $build_command = $self->build_command;

                    unless ( -e '.sigma6' ) {
                        $self->log( trace => 'mkdir .sigma6' );
                        system 'mkdir .sigma6';
                    }
                    $self->log( trace =>
                            "Smoker::Simple $deps_command &> $deps_file" );
                    system "$deps_command &> $deps_file";
                    $self->log( trace =>
                            "Smoker::Simple $build_command &> $build_file" );
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

