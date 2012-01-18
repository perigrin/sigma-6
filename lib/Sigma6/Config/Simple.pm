package Sigma6::Config::Simple;
use Moose;
use namespace::autoclean;

has config => (
    traits   => ['Hash'],
    isa      => 'HashRef',
    is       => 'ro',
    required => 1,
    handles  => {
        sections           => 'keys',
        get_section_config => 'get',
    }
);

with qw(Sigma6::Config);

around BUILDARGS => sub {
    my ( $next, $self ) = splice @_, 0, 2;
    if ( @_ == 1 && ref $_[0] eq 'HASH' ) {
        return $self->$next( config => shift );
    }
    my %p = @_;
    return $self->$next( config => \%p ) unless exists $p{config};
    return $self->$next(%p);

};

sub BUILD { $_[0]->add_plugins( $_[0]->sections ) }

1;
__END__
