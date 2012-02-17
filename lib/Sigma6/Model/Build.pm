package Sigma6::Model::Build;
use Moose;
use namespace::autoclean;
use Digest::SHA1 qw(sha1_hex);
use MooseX::Storage;

# ABSTRACT: Turn baubles into trinkets

with Storage( format => 'JSON' );

has [qw(target revision type description)] => (
    is  => 'ro',
    isa => 'Str',
);

has status => ( isa => 'Str', is => 'rw', );

has timestamp => ( is => 'ro', lazy => 1, default => sub {time} );

has id => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        sha1_hex( $_[0]->revision . $_[0]->timestamp );
    },
);

sub TO_JSON { shift->pack }

__PACKAGE__->meta->make_immutable;
1;
__END__
