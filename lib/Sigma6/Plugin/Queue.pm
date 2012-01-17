package Sigma6::Plugin::Queue;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Queue Plugin

extends qw(Sigma6::Plugin);

use Queue::Mmap;

for (qw(file size record_size mode)) {
    has $_ => (
        is       => 'ro',
        required => 1,
    );
}

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

with qw(Sigma6::Plugin::API::Queue);

1;
__END__
