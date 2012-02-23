package Sigma6::Plugin::API::RunSmoker;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: RunSmoker Plugin API

requires qw(smoker_command run_smoke);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 REQUIRED METHODS

=over4 

=item smoker_command

=item run_smoke

=back