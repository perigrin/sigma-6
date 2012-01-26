package Sigma6::Plugin::JSON;
use Moose;
use namespace::autoclean;
use JSON::Any;

extends qw(Sigma6::Plugin);

with qw(Sigma6::Plugin::API::RenderJSON);

sub render_build {
    JSON::Any->new( allow_blessed => 1 )->encode( $_[2] );
}

sub render_all_builds {
    JSON::Any->new( allow_blessed => 1 )->encode( $_[2] );
}

1;
__END__
