package Sigma6::Plugin::API::Smoker;
use Moose::Role;
use namespace::autoclean;

with qw(
    Sigma6::Plugin::API::SetupSmoker
    Sigma6::Plugin::API::CheckSmoker
    Sigma6::Plugin::API::StartSmoker
    Sigma6::Plugin::API::RunSmoker
    Sigma6::Plugin::API::TeardownSmoker
);

1;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

=over 4

=item L<Sigma6::Plugin::API::SetupSmoker>

=item L<Sigma6::Plugin::API::CheckSmoker>

=item L<Sigma6::Plugin::API::StartSmoker>

=item L<Sigma6::Plugin::API::RunSmoker>

=item L<Sigma6::Plugin::API::TeardownSmoker>

=back

