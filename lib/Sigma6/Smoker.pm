package Sigma6::Smoker;
use strict;

use Git::Repository;
use Cwd qw(chdir getcwd);
use Capture::Tiny qw(capture_merged);

sub new {
    my $class = shift;
    my %p = ref $_[0] ? %{ $_[0] } : @_;
    return bless \%p, $class;
}

sub initalize_repository {
    my ($self) = @_;
    unless ( -e $self->{temp_dir} ) {
        Git::Repository->run( clone => $self->{target} => $self->{temp_dir} );
    }
    return Git::Repository->new( work_tree => $self->{temp_dir} );
}

sub setup_workspace {
    my ( $self, $repo ) = @_;
    $repo->run('pull');
    $self->{previous_workspace} = getcwd;
    chdir $self->{temp_dir};
}

sub run_build {
    my ($self) = @_;
    $self->{build_output} = capture_merged sub {
        system $self->{deps_command};
        system 'PERL5LIB=$PERL5LIB:perl5/lib/perl5 ' . $self->{build_command};
    };
}

sub teardown_workspace {
    my ($self) = @_;
    chdir $self->{previous_workspace};
}

sub log_results {
    my ( $self, $repo, $output ) = @_;
    $repo->run( 'notes', 'add', '-fm', $output, 'HEAD' );
}

sub run {
    my $self = shift;

    my $repo = $self->initalize_repository;
    $self->setup_workspace($repo);
    $self->run_build($repo);
    $self->teardown_workspace($repo);
    $self->log_output( $repo, $self->{build_output} );
}

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
