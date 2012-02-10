package Sigma6::Plugin::Smoker::Simple;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Default Smoke Manager for unix like systems

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
    my $self       = shift;
    my $build_file = $self->build_file;
    return `cat $build_file` if -e $build_file;
    return '[nothing yet]';
}

sub start_smoker {
    my $self = shift;
    my $cmd  = $self->smoker_command;
    $self->die('No smoker_command') unless $cmd;
    if ( my $pid = fork ) {
        $self->warn("forked smoker as $pid");
        return $pid;
    }
    elsif ( defined $pid ) {
        $self->warn("starting smoker `$cmd` as $pid");
        exec('bin/smoker.pl', '--config sigma6.ini') or $self->die("Could not start `$cmd`: $!");
        exit;
    }
    else {
        $self->die("Could not fork: $!");
    }
}

sub setup_smoker    { }
sub teardown_smoker { }

sub run_smoke {
    my $self       = shift;
    my $deps_file  = $self->deps_file;
    my $build_file = $self->build_file;

    for my $builder ( $self->plugins_with('-SmokeEngine') ) {
        my $deps_command  = $builder->deps_command;
        my $build_command = $builder->build_command;
        system 'mkdir .sigma6' unless -e '.sigma6';
        system "$deps_command &> $deps_file";
        system "$build_command &> $build_file";
    }
}

sub teardown_smoke {

}

sub setup_workspace {
    my ( $self, $build_data ) = @_;
    mkdir $self->workspace unless -e $self->workspace;
    chdir $self->workspace;
    $ENV{PERL5LIB} .= ':perl5/lib/perl5';
}

sub teardown_workspace {
    my $self = shift;
    chdir $self->previous_workspace;
}

__PACKAGE__->meta->make_immutable;
1;
__END__
