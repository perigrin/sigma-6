package Sigma6::Plugin::API::SetupWorkspace;
use Moose::Role;
use namespace::autoclean;

requires qw(
    temp_dir
    previous_workspace
);

sub setup_workspace {
    my $self = shift;
    chdir $self->temp_dir;
    $ENV{PERL5LIB} .= ':perl5/lib/perl5';
}

1;
__END__
