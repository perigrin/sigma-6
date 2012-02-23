package Sigma6::Plugin::Github;
use Moose;
use namespace::autoclean;

# ABSTRACT: BuildData Plugin for Github Web Hooks

extends qw(Sigma6::Plugin);
with qw(Sigma6::Plugin::API::BuildData);

sub build_data {
    my ( $self, $data ) = @_;
    return unless $data->{payload};
    return { 'Git.target' => $data->{payload}{repository}{url}, };
}

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item build_data

=back