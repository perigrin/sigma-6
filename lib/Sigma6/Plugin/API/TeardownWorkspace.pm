package Sigma6::Plugin::API::TeardownWorkspace;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: TeardownWorkspace Plugin API

requires qw(teardown_workspace);

1;
__END__
