package Sigma6::Runner;
use Moose 1.01;
our $VERISON = '0.01';
use namespace::autoclean 0.09;
use Sigma6::Server;

extends qw(Plack::Runner);

around parse_options => sub {
    my ( $next, $self ) = splice @_, 0, 2;
    $self->$next(@_);
    $self->{app} = Sigma6::Server->run_psgi(@_);
    $ENV{'Sigma6.repo'} = shift @{ $self->{argv} };
};

1;
__END__
