package Sigma6::Plugin::Queue::Mmap;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Queue Plugin

extends qw(Sigma6::Plugin);

use Queue::Mmap;
use JSON::Any;

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
    $self->$next( JSON::Any->encode($data) );
};

around fetch_build => sub {
    my ( $next, $self ) = splice @_, 0, 2;
    my $data = $self->$next(@_);
    JSON::Any->decode($data);
};

with qw(Sigma6::Plugin::API::Queue);

1;
__END__
