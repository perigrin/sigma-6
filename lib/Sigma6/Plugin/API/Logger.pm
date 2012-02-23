package Sigma6::Plugin::API::Logger;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: Logging API

requires qw(
    logger
    trace
    debug
    notice
    warn
    die
);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

This is a base API for a Logging plugin.

=head1 REQUIRED METHODS

=over 4

=item logger() : Logger

Return the actual Logger instance

=item trace($message) 

Log something at a "trace" level. Trace in these terms is a mild form of
debugging used to make sure everything is flowing properly.

=item debug($message)

Log something at a "debug" level. This a more useful level than trace and is
typically used for digging out specific issues.

=item notice

Log something at a "notice" level. Notifications are for non-exception
logging.

=item warn

Log something at a 'warn' level. Warn is for non-fatal exception logging.

=item die

Log something at a 'die' level. Die is for fatal exception logging.

=back
