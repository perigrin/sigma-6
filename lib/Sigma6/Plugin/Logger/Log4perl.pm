package Sigma6::Plugin::Logger::Log4perl;
use Moose;
use namespace::autoclean;

# ABSTRACT: A Logger Plugin using Log4perl

use Log::Log4perl;
use Moose::Util::TypeConstraints;

extends qw(Sigma6::Plugin);

has config => (
    is  => 'ro',
    isa => 'Str',
);

has logger => (
    is      => 'ro',
    isa     => 'Log::Log4perl::Logger',
    lazy    => 1,
    builder => '_build_logger',
    handles => {
        trace  => 'trace',
        debug  => 'debug',
        notice => 'info',
        warn   => 'warn',
        die    => 'logconfess',
    },
);

sub _build_logger {
    Log::Log4perl->init( shift->config );
    Log::Log4perl->get_logger('Sigma6');
}

with qw(Sigma6::Plugin::API::Logger);

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

Implements the Logging API using a Log4perl instance. 

=head1 ATTRIBUTES

=over 4

=item config

=item logger

=back 

=head1 METHODS

=over 4

=item config

Returns the configuration file name (for passing to C<Log::Log4per->init()>).

=item logger

Returns the configured C<Log::Log4perl::Logger> object.

=item trace  

Maps to C<trace> in L<Log::Log4perl>.

=item debug  

Maps to C<debug> in L<Log::Log4perl>.

=item notice

Maps to C<info> in L<Log::Log4perl>.

=item warn

Maps to C<warn> in L<Log::Log4perl>.

=item die

Maps to C<logconfess> in L<Log::Log4perl>.

=back

