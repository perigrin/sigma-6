package Sigma6::Plugin::API::CheckBuild;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: CheckBuilds Plugin API

requires qw( check_all_builds check_build );

1;
__END__
