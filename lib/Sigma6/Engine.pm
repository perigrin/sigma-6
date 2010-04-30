package Sigma6::Engine;
use Moose 1.01;
our $VERSION = '0.01';
use namespace::autoclean 0.09;

use MooseX::Types::Path::Class qw(File);
with qw(MooseX::Workers);

has repo         => ( isa => 'Str', is => 'ro', required => 1 );
has build_script => ( isa => 'Str', is => 'ro', required => 1, );

has status_file => (
    isa      => File,
    is       => 'ro',
    required => 1,
    coerce   => 1,
    handles  => { 'build_status' => 'slurp', has_file => 'stat' }
);

sub status {
    my $self = shift;
    return { status => 'No Build Yet' } unless $self->has_file;

    return {
        status       => 'Building…',
        build_status => scalar $self->build_status
      }
      if $self->has_workers;

    return {
        status       => 'Build Complete',
        build_status => scalar $self->build_status
    };

}

sub start_build {
    my $self = shift;
    $self->spawn(
        sub {
            $|++;
            $0 = blessed($self) . ' Worker';
            my $out = $self->status_file->openw;
            $out->print('Build Started');
            for ( 1 .. 60 ) { sleep 1; $out->print("Build $_\n"); }
            $out->print('Build Complete');
            exit;
        }
    );
}

1;
__END__
