package Sigma6::Plugin::Dzil;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 Dist::Zilla Plugin

extends qw(Sigma6::Plugin);
with qw(Sigma6::Plugin::API::BuildSystem);

sub deps_command {
    $_[0]->get_config( key => 'dzil.deps_command' );
}

sub build_command {
    $_[0]->get_config( key => 'dzil.build_command' );
}

__PACKAGE__->meta->make_immutable;
1;
__END__
