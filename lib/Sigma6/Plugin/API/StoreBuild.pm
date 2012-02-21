package Sigma6::Plugin::API::StoreBuild;
use Moose::Role;
use namespace::autoclean;

requires qw(
    get_build
    builds
    store_build
    update_build
    clear_build
);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 REQUIRED METHODS

=over 4

=item get_build

=item builds

=item store_build

=item update_build

=item clear_build

=back

