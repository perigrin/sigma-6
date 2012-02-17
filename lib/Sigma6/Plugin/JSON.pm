package Sigma6::Plugin::JSON;
use Moose;
use namespace::autoclean;
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
