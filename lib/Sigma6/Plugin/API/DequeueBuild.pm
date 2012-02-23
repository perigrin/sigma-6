package Sigma6::Plugin::API::DequeueBuild;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: DequeueBuild Plugin API

requires qw(fetch_build);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

API for fetching things from the Smoker Queue.

=head1 REQUIRED METHODS

=over 4

=item fetch_build

=back

