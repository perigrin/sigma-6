package Sigma6::Plugin::API::RenderOutput;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: API for RenderOutput plugins

requires qw(render);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

Generic Render API. This is used by both the RenderHTML and RenderJSON plugins.

=head1 REQUIRED METHODS

=over4 

=item render

=back
