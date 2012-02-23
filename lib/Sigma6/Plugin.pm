package Sigma6::Plugin;
use Moose;
use namespace::autoclean;

# ABSTRACT: The base class for Sigma6 Plugins

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
);

sub log {
    my ( $self, $level, $message ) = @_;
    for ( $self->plugins_with('-Logger') ) {
        $_->$level($message);
    }
}

sub warn { shift->log( warn => @_ ) }
sub die  { shift->log( die  => @_ ) }

__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME 

Sigma6::Plugin

=head1 SYNOPSIS

    package Sigma6::Plugin::AwesomeNess
    use Moose;
    
    extends qw(Sigma6::Plugin);
    
    ... 
    
    1;
    __END__

=head1 DESCRIPTION

This is the base class for Sigma6::Plugins. It exists basically to sit at the
top of the plugin tree. It does provide some basic shared behavior for all
plugins.

=head1 ATTRIBUTES

=over 4 

=item config

This holds the L<Sigma6::Config> object and delegates the L<Sigma6::Config>
API.

=back

=head1 METHODS

=over 4

=item log ($level, $message)

Calls C<$logger->$level($message)> for each C<Logger> configured in the
system.

=item warn ($message)

A convience wrapper for C<$self->log( warn => $message)>

=item die ($message)

A convience wrapper for C<$self->log( die => $message)>

=back
