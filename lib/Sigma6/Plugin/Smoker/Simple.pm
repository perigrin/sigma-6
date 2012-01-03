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

with qw(
    Sigma6::Plugin::API::SetupSmoker
    Sigma6::Plugin::API::CheckSmoker
    Sigma6::Plugin::API::StartSmoker
    Sigma6::Plugin::API::RunSmoker
    Sigma6::Plugin::API::TeardownSmoker

    Sigma6::Plugin::API::SetupWorkspace
    Sigma6::Plugin::API::TeardownWorkspace
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

sub workspace {
    my $self = shift;
    my $dir = $self->get_config( key =>'Smoker::Simple.workspace' );
    mkdir $dir unless -e $dir;
    my $id = $self->target_name;
    return "$dir/$id";
}

sub setup_workspace {
    my $self = shift;
    mkdir $self->workspace unless -e $self->workspace;
    chdir $self->workspace;
    $ENV{PERL5LIB} .= ':perl5/lib/perl5';
}

sub target_name {
    shift->first_from_plugin_with( '-Repository' => sub { shift->target_name }
    );
}

sub smoker_status {
    my $self       = shift;
    my $build_file = $self->build_file;
    return `cat $build_file` if -e $build_file;
    return '[nothing yet]';
}


sub smoker_command {
    $_[0]->get_config( key =>  'Smoker::Simple.smoker_command' );
}

sub start_smoker {
    my $self = shift;
    my $cmd  = $self->smoker_command;
    confess 'No smoker_command' unless $cmd;
    if ( my $pid = fork ) {
        return $pid;
    }
    elsif ( defined $pid ) {
        exec($cmd);
        exit;
    }
    else {
        confess "Could not fork: $!";
    }
}

sub setup_smoker {
    
}

sub run_smoke {
    my $self       = shift;
    my $deps_file  = $self->deps_file;
    my $build_file = $self->build_file;

    for my $builder ( $self->plugins_with('-SmokeCommands') ) {
        my $deps_command  = $builder->deps_command;
        my $build_command = $builder->build_command;
        system 'mkdir .sigma6' unless -e '.sigma6';
        system "$deps_command &> $deps_file";
        system "$build_command &> $build_file";
    }
}

sub teardown_smoke {
    
}

sub teardown_workspace {
    my $self = shift;
    chdir $self->previous_workspace;
}

__PACKAGE__->meta->make_immutable;
1;
__END__
