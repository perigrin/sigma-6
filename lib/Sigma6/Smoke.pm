package Sigma6::Smoke;
{
  $Sigma6::Smoke::VERSION = '0.001';
}
use strict;

use Git::Repository;
use Capture::Tiny qw(capture_merged);

sub new {
    my $class = shift;
    my %p = ref $_[0] ? %{ $_[0] } : @_;
    return bless \%p, $class;
}

sub run {
    my $self = shift;
    unless ( -e $self->{temp_dir} ) {
        Git::Repository->run( clone => $self->{target} => $self->{temp_dir} );
    }

    my $repo = Git::Repository->new( work_tree => $self->{temp_dir} );
    $repo->run('pull');

    my $start = getcwd;
    chdir $self->{temp_dir};
    my $output = capture_merged sub {
        system $self->{deps_command};
        system 'PERL5LIB=$PERL5LIB:perl5/lib/perl5 ' . $self->{build_command};
    };
    $repo->run( 'notes', 'add', '-fm', $output, 'HEAD' );
    chdir $start;
}
