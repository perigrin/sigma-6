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
