package Sigma6::Model::Build;
use Moose;
use namespace::autoclean;

# ABSTRACT: An Object to represent builds in Sigma6.

use Digest::SHA1 qw(sha1_hex);
use MooseX::Storage;

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

=head1 NAME

Sigma6::Model::Build

=head1 SYNOPSIS

    Sigma6::Model::Build->new(
        target => 'git@github.com:perigrin/sigma6.git',
        type   => 'git'
    );

=head1 DESCRIPTION

This is the main class that models a single build or smoke-run in the system.

=head1 METHODS

=over 4

=item id ()

A calculated unique ID for this build for tracking and storage purposes.

=item target ()

The upstream target that we pulled the current code for. This might be a Git
repository, or a CPAN module.

=item type ()

The type of build, for example for CPAN distributions this would be set to
'cpan'.

=item revision ()

The current revision that is being built. In git terms this is the SHA1 of the
current HEAD commit, in CPAN terms this is the version of the distribution
being tested.

=item description ()

A human readable description of the current revision for Repositories that
support that.

=item status ($status)

The only piece of mutable state in the object, this tracks the current status
of the build.

=item TO_JSON ()

Uses L<MooseX::Storage> to return a representation of the object for JSON::XS
to properly serialize.

