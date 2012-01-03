package Sigma6::Plugin::API::Repository;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: Repository Plugin API

requires qw(target repository);

1;
__END__