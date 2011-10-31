package Sigma6::Plugin::Dzil;
use Moose;
use namespace::autoclean;

extends qw(Sigma6::Plugin);

use Cwd qw(chdir getcwd);

has previous_workspace => (
    isa     => 'Str',
    is      => 'ro',
    default => sub { getcwd() },
);

sub temp_dir;

with qw(
    Sigma6::Plugin::API::SetupWorkspace
    Sigma6::Plugin::API::TeardownWorkspace
);

__PACKAGE__->meta->make_immutable;
1;
__END__
