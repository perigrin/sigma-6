package Sigma6::Plugin::CPAN;
use Moose;
use namespace::autoclean;

# ABSTRACT: Sigma6 CPAN Plugin

extends qw(Sigma6::Plugin);
with qw(Sigma6::Plugin::API::SmokeEngine);

sub deps_command {
    $_[0]->get_config( key => 'CPAN.deps_command' );
}

sub build_command {
    $_[0]->get_config( key => 'CPAN.build_command' );
}

__PACKAGE__->meta->make_immutable;
1;
__END__
