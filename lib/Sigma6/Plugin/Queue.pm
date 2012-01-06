package Sigma6::Plugin::Queue;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Queue Plugin

extends qw(Sigma6::Plugin);

use Queue::Mmap;

for (qw(file size record_size mode)) {
    has $_ => (
        is       => 'ro',
        lazy     => 1,
        required => 1,
    );
}

has queue => (
    isa     => 'Queue::Mmap',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_queue'
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

1;
__END__
