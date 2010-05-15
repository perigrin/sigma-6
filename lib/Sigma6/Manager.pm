package Sigma6::Manager;
use Moose 1.01;
our $VERSION = '0.01';
use namespace::autoclean 0.09;

use MooseX::Types::Path::Class qw(Dir File);
with qw(MooseX::Workers);

has repo => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

has build_script => (
    isa      => File,
    is       => 'ro',
    coerce   => 1,
    required => 1,
);

has build_dir => (
    isa      => Dir,
    is       => 'ro',
    coerce   => 1,
    required => 1
);

has status_file => (
    isa      => File,
    is       => 'ro',
    required => 1,
    coerce   => 1,
    handles  => { 'build_status' => 'slurp', has_file => 'stat' }
);

sub status {
    my $self = shift;

    if ( !$self->has_file ) {
        return { status => 'No Build Yet' };
    }
    elsif ( $self->has_workers ) {
        return {
            status       => 'Building…',
            build_status => scalar $self->build_status
        };
    }
    else {
        return {
            status       => 'Build Complete',
            build_status => scalar $self->build_status
        };
    }
}

sub start_build {
    my $self = shift;
    $self->spawn(
        sub {
            $0 = blessed($self) . ' Worker';
            my $out = $self->status_file->openw;
            $out->autoflush(1);
            system(
                '/bin/bash' => $self->build_script->resolve,
                '&>' . $self->status_file
            );
            exit;
        }
    );
}

1;
__END__
