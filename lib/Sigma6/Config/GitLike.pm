package Sigma6::Config::GitLike;
use Moose;
use namespace::autoclean;

extends qw(Config::GitLike);

with qw(Sigma6::Config);

use File::Spec;
use Moose::Util::TypeConstraints;

has '+confname' => ( default => 'sigma6.ini' );

sub dir_file {
    my $self = shift;
    return $self->confname;
}

sub user_file {
    my $self = shift;
    my $name = $self->confname;
    $name =~ s/.ini$//;
    return File::Spec->catfile( $ENV{'HOME'}, ".$name" );
}

around 'define' => sub {
    my ( $next, $self, %args ) = @_;
    $self->add_plugins( $args{section} ) if $args{section};
    $self->$next(%args);
};

1;
__END__