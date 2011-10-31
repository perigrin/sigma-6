package Sigma6::Plugin::System;
use Moose;
use namespace::autoclean;

extends qw(Sigma6::Plugin);

with qw(
    Sigma6::Plugin::API::SmokerCommand
    Sigma6::Plugin::API::TempDir
);

sub temp_dir {
    return $_[0]->get_config( key => 'system.temp_dir' );
}

sub smoker_command {
    return $_[0]->get_config( key => 'system.smoker_command' );
}

__PACKAGE__->meta->make_immutable;
1;
__END__
