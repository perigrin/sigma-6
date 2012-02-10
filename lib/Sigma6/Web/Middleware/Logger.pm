package Sigma6::Web::Middleware::Logger;
use Moose;
use namespace::autoclean;

# ABSTRACT: Turn baubles into trinkets

extends qw(Plack::Middleware);

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
);

sub call {
    my ( $self, $env ) = @_;
    $env->{'psgix.logger'} = sub {
        my $args  = shift;
        my $level = $args->{level};
        for ( $self->plugins_with('-Logger') ) {
            $_->$level( "Web $args->{message}" );
        }
    };
    $self->app->($env);
}

#__PACKAGE__->meta->make_immutable;
1;
__END__
