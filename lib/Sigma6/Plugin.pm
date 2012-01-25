package Sigma6::Plugin;
use Moose;
use namespace::autoclean;

# ABSTRACT: The base class for Sigma6 Plugins

has config => (
    does     => 'Sigma6::Config',
    is       => 'ro',
    required => 1,
    handles  => 'Sigma6::Config',
);

sub name { 
    my ($name) = shift->meta->name =~ m/::(\w+)$/;
    return $name;
}

__PACKAGE__->meta->make_immutable;
1;
__END__


=head1 NAME Sigma6::Plugin

