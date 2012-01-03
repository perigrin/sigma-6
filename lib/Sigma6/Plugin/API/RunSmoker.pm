package Sigma6::Plugin::API::RunSmoker;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: RunSmoker Plugin API

requires qw(smoker_command run_smoke);

1;
__END__
