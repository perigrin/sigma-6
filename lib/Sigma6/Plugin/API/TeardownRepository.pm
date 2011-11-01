package Sigma6::Plugin::API::TeardownRepository;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: TeardownRepository Plugin API

requires qw( teardown_repository );

1;
__END__
