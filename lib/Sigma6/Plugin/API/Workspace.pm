package Sigma6::Plugin::API::Workspace;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: Workspace Plugin API

with qw(
    Sigma6::Plugin::API::SetupWorkspace
    Sigma6::Plugin::API::TeardownWorkspace
);

requires qw(workspace);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

=over 4

=item L<Sigma6::Plugin::API::SetupWorkspace>

=item L<Sigma6::Plugin::API::TeardownWorkspace>

=back