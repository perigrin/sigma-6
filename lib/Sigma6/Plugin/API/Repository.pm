package Sigma6::Plugin::API::Repository;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: Repository Plugin API

with qw(
    Sigma6::Plugin::API::SetupRepository
    Sigma6::Plugin::API::TeardownRepository
);

requires qw(
    repository
    revision
    revision_description
    revision_status
    repository_directory
    target
);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

This is the API for a Repository plugin. A Repository is a source for a build,
typically a source control system like Git. 

=head1 REQUIRED METHODS

=over 4

=item repository

=item revision

=item revision_description

=item revision_status

=item repository_directory

=item target

=back 

=head2 SEE ALSO

=over4

=item L<Sigma6::Plugin::API::SetupRepository>

=item L<Sigma6::Plugin::API::TeardownRepository>

=back
