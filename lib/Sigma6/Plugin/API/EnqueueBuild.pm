package Sigma6::Plugin::API::EnqueueBuild;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: EnqueueBuild Plugin API

requires qw(push_build);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

API for adding things to the Smoker Queue.

=head1 REQUIRED METHODS

=over 4

=item push_build

=back

