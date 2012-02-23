package Sigma6::Plugin::API::RecordResults;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT RecordResults Plugin API

requires qw(record_results);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

API for Plugin that Records results to some external storage or reporting
facility.

=head1 REQUIRED METHODS

=over 4

=item record_results

=back 
