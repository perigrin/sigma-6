package Sigma6::Plugin;
use Moose;

has config => (
    isa      => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => { get_config => 'get' },
);

1;
__END__