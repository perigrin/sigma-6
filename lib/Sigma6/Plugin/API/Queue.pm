package Sigma6::Plugin::API::Queue;
use Moose::Role;

with qw(
    Sigma6::Plugin::API::EnqueueBuild
    Sigma6::Plugin::API::DequeueBuild
);

1;
__END__
