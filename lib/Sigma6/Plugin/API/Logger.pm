package Sigma6::Plugin::API::Logger;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: Turn baubles into trinkets

requires qw(logger warn die);

1;
__END__
