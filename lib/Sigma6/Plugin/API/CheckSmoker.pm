package Sigma6::Plugin::API::CheckSmoker;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: BuildSystem Plugin API

requires qw(smoker_status);

1;
__END__
