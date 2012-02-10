package Sigma6::Model::Build;
use Moose;
use namespace::autoclean;
use MooseX::Storage;
# ABSTRACT: Turn baubles into trinkets
with Storage(format => 'JSON');


has [qw(target id status type description)] => (
    is  => 'rw',
    isa => 'Str',
);


__PACKAGE__->meta->make_immutable;
1;
__END__
