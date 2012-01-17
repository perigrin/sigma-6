package Sigma6::Plugin::API::Repository;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: Repository Plugin API

with qw(
    Sigma6::Plugin::API::SetupRepository
    Sigma6::Plugin::API::TeardownRepository
);

requires qw(
    repository
    commit_id
    commit_description
    commit_status
    target
);

1;
__END__
