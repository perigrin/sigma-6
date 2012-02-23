package Sigma6::Plugin::API::RenderJSON;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: API for RenderJSON plugins

with qw(Sigma6::Plugin::API::RenderOutput);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

API for Rendering JSON Output.

=head1 SEE ALSO

=over4 

=item L<Sigma6::Plugin::API::RenderOutput>

=back