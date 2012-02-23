package Sigma6::Plugin::API::SmokeEngine;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: BuildSystem Plugin API

requires qw(deps_command build_command smoke_build);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 REQUIRED METHODS

=over4 

=item deps_command

=item build_command

=item smoke_build

=back 
