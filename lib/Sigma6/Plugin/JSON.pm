package Sigma6::Plugin::JSON;
use Moose;
use namespace::autoclean;

# ABSTRACT: A RenderOutput Plugin for JSON

use JSON::Any;

extends qw(Sigma6::Plugin);

with qw(Sigma6::Plugin::API::RenderJSON);

sub render {
    my ( $self, $res, $data ) = @_;
    $res->content_type('application/json');
    return JSON::Any->new(
        convert_blessed => 1,
        utf8            => 1,
        pretty          => 1,
    )->encode($data);
}

1;
__END__


=head1 NAME

SIgma6::Plugin::JSON

=head1 DESCRIPTION

Render Build Data as JSON.

=head1 METHODS

=over 4

=item render ($response, $data)

Render C<$data> as JSON. Set the response content_type to "application/json".

=back

