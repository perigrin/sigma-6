package Sigma6::Plugin::API::SmokeEngine;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: BuildSystem Plugin API

requires qw(deps_command build_command);

1;
__END__
