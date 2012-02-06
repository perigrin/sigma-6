package Sigma6::Plugin::EmberJS;
use Moose;
use namespace::autoclean;

# ABSTRACT: Turn baubles into trinkets

extends qw(Sigma6::Plugin);
with qw(Sigma6::Plugin::API::BuildData);

sub build_data {
    $_[1]->{target} ||= delete $_[1]->{'builds[target]'};
}

__PACKAGE__->meta->make_immutable;
1;
__END__
