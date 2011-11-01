package Sigma6::Plugin::API::StartSmoker;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: StartSmoker Plugin API

requires qw(start_smoker smoker_command);

1;
__END__
