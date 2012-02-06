package Sigma6::Model::Build;
use Moose;
use namespace::autoclean;

# ABSTRACT: Turn baubles into trinkets

has [qw(target id status type description)] => (
    is  => 'rw',
    isa => 'Str',
);


__PACKAGE__->meta->make_immutable;
1;
__END__
