package Sigma6::Web::Middleware::Logger;
use Moose;
use namespace::autoclean;

# ABSTRACT: Logging for Plack that use the Sigma6 loggers.

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

1;
__END__

=head1 NAME 

Sigma6::Web::Middleware::Logger

=head1 SYNOPSIS

    builder { 
    ...
        enable '+Sigma6::Web::Middleware::Logger' => (
            config => $self->config,
        );
    ...
    }
    
=head1 DESCRIPTION

This is Logging middleware to use the Sigma6 plugin system for logging in
Plack. It sets $env->{'psgix.logger'} to a subroutine that take standard Plack
logging directives, C<{ level => $lvl, message => $message}>, and passes them
to the plugins that do the Logger API.

