package Sigma6::Plugin::API::CheckBuilds;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: CheckBuild Plugin API

requires qw( check_builds );

1;
__END__
