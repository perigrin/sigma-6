package Sigma6::Plugin::API::CheckBuild;
use Moose::Role;
use namespace::autoclean;

# ABSTRACT: CheckBuild Plugin API

requires qw( check_all_builds check_build );

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

CheckBuild plugins report on the status of a given build, or of all builds
currently known by the plugin.

=head1 REQUIRED METHODS

=over 4

=item check_all_builds

=item check_builds

=back