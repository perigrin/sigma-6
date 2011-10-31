package Sigma6::Plugin;
use Moose;

has config => (
    isa      => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
);

__PACKAGE__->meta->make_immutable;
1;
__END__
