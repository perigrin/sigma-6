package Sigma6::Plugin::API::CheckSmoker;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: BuildSystem Plugin API

requires qw(check_smoker);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

CheckSmoker plugins report on the status of smoker for a given build.

=head1 REQUIRED METHODS

=over 4

=item check_smoker

=back

