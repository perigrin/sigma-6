package Sigma6::Plugin::MiniCPAN;
use Moose;
use namespace::autoclean;
use CPAN::Mini;

# ABSTRACT: Sigma6 MiniCPAN Plugin

extends qw(Sigma6::Plugin);

with qw(
    Sigma6::Plugin::API::SetupWorkspace
);

has [qw(remote local)] => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub setup_workspace {
    my $self = shift;

    CPAN::Mini->update_mirror(
        remote    => $self->remote,
        local     => $self->local,
        skip_perl => 1,
        log_level => 'fatal',
    );

}

1;
__END__

