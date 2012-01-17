package Sigma6::Plugin::API::Workspace;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: Workspace Plugin API

with qw(
    Sigma6::Plugin::API::SetupWorkspace
    Sigma6::Plugin::API::TeardownWorkspace
);

requires qw(workspace);

1;
__END__
