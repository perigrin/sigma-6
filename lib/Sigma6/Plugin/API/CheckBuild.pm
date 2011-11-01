package Sigma6::Plugin::API::CheckBuild;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: CheckBuild Plugin API

requires qw( build_status );

1;
__END__
