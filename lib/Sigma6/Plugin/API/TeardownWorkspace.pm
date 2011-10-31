package Sigma6::Plugin::API::TeardownWorkspace;
use Moose::Role;
use namespace::autoclean;

requires qw(previous_workspace);

sub teardown_workspace {
    chdir $_[0]->previous_workspace;
}

1;
__END__
