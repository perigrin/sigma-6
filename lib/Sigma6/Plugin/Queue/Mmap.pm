package Sigma6::Plugin::Queue::Mmap;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Queue Plugin

extends qw(Sigma6::Plugin);

use Queue::Mmap;

has [qw(file size record_size mode)] => (
    is       => 'ro',
    required => 1,
);

has queue => (
    isa     => 'Queue::Mmap',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_queue',
    handles => {
        fetch_build => 'pop',
        push_build  => 'push',
    }
);

sub _build_queue {
    my $self = shift;
    Queue::Mmap->new(
        file   => $self->file,
        queue  => $self->size,
        length => $self->record_size,
        mod    => $self->mode,
    );
}

around push_build => sub {
    my ( $next, $self, $data ) = splice @_, 0, 3;
    $self->log( trace => "Queue adding build" );
    $self->$next( $data->{id} );
};

around fetch_build => sub {
    my ( $next, $self ) = splice @_, 0, 2;
    $self->log( trace => "Queue fetching build" );
    my $build_id = $self->$next(@_);
    return unless defined $build_id;
    $self->log( debug => "Queue Got Id: $build_id" );
    my $build = $self->first_from_plugin_with(
        '-BuildManager' => sub { $_[0]->get_build($build_id) } );
    return $build;
};

with qw(Sigma6::Plugin::API::Queue);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=item file

=item size 

=item record_size

=item mode

=item queue

=head1 METHODS

=over 4

=item file

=item size 

=item record_size

=item mode

=item fetch_build

=item push_build

=back
