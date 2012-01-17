package Sigma6::Plugin::API::BuildManager;
use Moose::Role;
use namespace::autoclean;

with qw(
    Sigma6::Plugin::API::CheckBuild
    Sigma6::Plugin::API::StartBuild
);

1;
__END__
